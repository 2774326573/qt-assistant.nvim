-- Asynchronous, bounded directory walker used for project discovery.
-- File enumeration is sliced so large directories do not monopolize Neovim's UI.
local M = {}
local uv = vim.uv or vim.loop

local ignored = {
    [".git"] = true, [".hg"] = true, [".svn"] = true,
    [".idea"] = true, [".vs"] = true, [".vscode"] = true,
    ["build"] = true, ["out"] = true, ["bin"] = true,
    ["obj"] = true, ["debug"] = true, ["release"] = true,
    ["node_modules"] = true, [".venv"] = true, ["venv"] = true,
    ["third_party"] = true, ["vendor"] = true, [".cache"] = true,
    ["_build"] = true, ["cmakefiles"] = true,
}

function M.ignore_directory(name)
    local lower = name:lower()
    return ignored[lower] or lower:match("^cmake%-build%-") ~= nil
end

--- Walk a directory tree without blocking the UI while filesystem operations run.
--- match(name, dir) must return a result path (or nil).
--- The returned function cancels the walk without invoking the callback.
function M.walk(opts, callback)
    opts = opts or {}
    assert(type(callback) == "function", "async_scan.walk requires a callback")
    assert(type(opts.match) == "function", "async_scan.walk requires a match function")

    local root = vim.fs.normalize(opts.root or vim.fn.getcwd())
    local max_depth = math.max(0, math.floor(tonumber(opts.depth) or 3))
    local max_dirs = math.max(1, math.floor(tonumber(opts.max_dirs) or 1200))
    local max_entries = math.max(1, math.floor(tonumber(opts.max_entries) or 25000))
    local limit = math.max(1, math.floor(tonumber(opts.limit) or 20))
    local batch_size = math.max(1, math.min(tonumber(opts.batch_size) or 128, 512))
    local queue = { { path = root, depth = 0 } }
    local queued = { [root] = true }
    local results, result_seen = {}, {}
    local head, visited_dirs, visited_entries = 1, 0, 0
    local cancelled, finished = false, false

    local function finish(reason)
        if cancelled or finished then return end
        finished = true
        local stats = {
            reason = reason,
            directories = visited_dirs,
            entries = visited_entries,
            truncated = reason ~= "complete",
        }
        vim.schedule(function()
            if not cancelled then callback(results, stats) end
        end)
    end

    local next_directory
    next_directory = function()
        if cancelled or finished then return end
        if #results >= limit then return finish("limit") end
        if visited_dirs >= max_dirs then return finish("directory_limit") end
        if visited_entries >= max_entries then return finish("entry_limit") end
        if head > #queue then return finish("complete") end

        local dir = queue[head]
        head = head + 1
        visited_dirs = visited_dirs + 1

        uv.fs_scandir(dir.path, function(err, handle)
            if cancelled or finished then return end
            if err or not handle then
                vim.schedule(next_directory)
                return
            end

            local function process_batch()
                if cancelled or finished then return end
                local exhausted = false
                for _ = 1, batch_size do
                    local name, kind = uv.fs_scandir_next(handle)
                    if not name then
                        exhausted = true
                        break
                    end
                    visited_entries = visited_entries + 1

                    if kind == "directory" and dir.depth < max_depth
                        and not M.ignore_directory(name) then
                        local child = dir.path .. "/" .. name
                        if not queued[child] and #queue < max_dirs then
                            queued[child] = true
                            table.insert(queue, { path = child, depth = dir.depth + 1 })
                        end
                    elseif kind == "file" then
                        local result = opts.match(name, dir.path)
                        if result and not result_seen[result] then
                            result_seen[result] = true
                            table.insert(results, result)
                        end
                    end

                    if #results >= limit or visited_entries >= max_entries then
                        exhausted = true
                        break
                    end
                end
                if exhausted then
                    vim.schedule(next_directory)
                else
                    vim.schedule(process_batch)
                end
            end
            vim.schedule(process_batch)
        end)
    end

    vim.schedule(next_directory)
    return function()
        cancelled = true
    end
end

return M
