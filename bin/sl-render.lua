#!/usr/bin/env lua
-- =============================================================================
--  Shoelace Pure-Lua Template Renderer (sl-render)
--  Single Source of Truth: env/shoelace.toml (or env/shoelace.config)
-- =============================================================================

local function file_or_dir_exists(path)
    if not path or path == "" then return false end
    local f = io.open(path, "r")
    if f then
        f:close()
        return true
    end
    local f_dir = io.open(path .. "/.", "r")
    if f_dir then
        f_dir:close()
        return true
    end
    return false
end

local function get_root_dir()
    local env_dir = os.getenv("SHOELACE_DIR") or os.getenv("DOTFILES_DIR")
    if env_dir and env_dir ~= "" then
        return env_dir:gsub("^~", os.getenv("HOME") or "")
    end

    local script_path = arg and arg[0]
    if not script_path or script_path == "" or script_path:sub(1,1) == "=" then
        local src = debug.getinfo(1, "S").source
        if src and src:sub(1,1) == "@" then
            script_path = src:sub(2)
        end
    end

    if script_path and script_path ~= "" then
        local p = io.popen('readlink -f "' .. script_path .. '" 2>/dev/null')
        if p then
            local real = p:read("*l")
            p:close()
            if real and real ~= "" then
                local dir = real:match("(.*/)")
                if dir then
                    local root = dir:gsub("/bin/?$", "")
                    if file_or_dir_exists(root .. "/env") or file_or_dir_exists(root .. "/shoelace.toml") then
                        return root
                    end
                end
            end
        end
    end

    local cwd_p = io.popen("pwd 2>/dev/null")
    if cwd_p then
        local cwd = cwd_p:read("*l")
        cwd_p:close()
        if cwd and (file_or_dir_exists(cwd .. "/env") or file_or_dir_exists(cwd .. "/shoelace.toml")) then
            return cwd
        end
    end

    local home = os.getenv("HOME") or ""
    if home ~= "" then
        local candidates = { home .. "/shoelace", home .. "/dot" }
        for _, c in ipairs(candidates) do
            if file_or_dir_exists(c .. "/env") or file_or_dir_exists(c .. "/shoelace.toml") then return c end
        end
    end

    return "."
end

local ROOT_DIR = get_root_dir()

-- -----------------------------------------------------------------------------
-- 1. Mini Pure-Lua TOML Parser
-- -----------------------------------------------------------------------------
local function parse_toml_value(val_str)
    val_str = val_str:match("^%s*(.-)%s*$")
    if not val_str or val_str == "" then return nil end

    -- String in double quotes
    if val_str:sub(1, 1) == '"' and val_str:sub(-1) == '"' then
        return val_str:sub(2, -2):gsub('\\"', '"'):gsub('\\n', '\n'):gsub('\\t', '\t')
    end
    -- String in single quotes
    if val_str:sub(1, 1) == "'" and val_str:sub(-1) == "'" then
        return val_str:sub(2, -2)
    end
    -- Boolean
    if val_str == "true" then return true end
    if val_str == "false" then return false end
    -- Number (integer or float)
    local num = tonumber(val_str)
    if num ~= nil then return num end

    -- Array: [ ... ]
    if val_str:sub(1, 1) == "[" and val_str:sub(-1) == "]" then
        local inner = val_str:sub(2, -2)
        local arr = {}
        for item in inner:gmatch("([^,]+)") do
            local pv = parse_toml_value(item)
            if pv ~= nil then
                table.insert(arr, pv)
            end
        end
        return arr
    end

    -- Inline table: { ... }
    if val_str:sub(1, 1) == "{" and val_str:sub(-1) == "}" then
        local inner = val_str:sub(2, -2)
        local tbl = {}
        for k, v in inner:gmatch("([%w_%-]+)%s*=%s*([^,]+)") do
            tbl[k] = parse_toml_value(v)
        end
        return tbl
    end

    return val_str
end

local function parse_toml_file(filepath)
    local f = io.open(filepath, "r")
    if not f then return nil end
    local content = f:read("*a")
    f:close()

    local result = {}
    local current_table = result

    local multiline_key = nil
    local multiline_buf = ""

    for line in content:gmatch("[^\r\n]+") do
        local clean = line:match("^%s*(.-)%s*$")
        if clean and clean ~= "" and clean:sub(1, 1) ~= "#" then
            local in_quote = false
            local stripped = ""
            for i = 1, #clean do
                local c = clean:sub(i, i)
                if c == '"' and clean:sub(i - 1, i - 1) ~= '\\' then
                    in_quote = not in_quote
                elseif c == '#' and not in_quote then
                    break
                end
                stripped = stripped .. c
            end
            clean = stripped:match("^%s*(.-)%s*$")

            if clean and clean ~= "" then
                if multiline_key then
                    multiline_buf = multiline_buf .. " " .. clean
                    if clean:find("%]") then
                        current_table[multiline_key] = parse_toml_value(multiline_buf)
                        multiline_key = nil
                        multiline_buf = ""
                    end
                else
                    -- Array of Tables: [[table.name]]
                    local aot_name = clean:match("^%[%[([%w_%-%.]+)%]%]$")
                    if aot_name then
                        local parts = {}
                        for part in aot_name:gmatch("[^%.]+") do table.insert(parts, part) end
                        local cur = result
                        for i = 1, #parts - 1 do
                            local k = parts[i]
                            if not cur[k] then cur[k] = {} end
                            cur = cur[k]
                        end
                        local final_key = parts[#parts]
                        if not cur[final_key] or type(cur[final_key]) ~= "table" then
                            cur[final_key] = {}
                        end
                        local new_tbl = {}
                        table.insert(cur[final_key], new_tbl)
                        current_table = new_tbl
                    else
                        -- Standard Table: [table.name]
                        local tbl_name = clean:match("^%[([%w_%-%.]+)%]$")
                        if tbl_name then
                            local parts = {}
                            for part in tbl_name:gmatch("[^%.]+") do table.insert(parts, part) end
                            local cur = result
                            for i = 1, #parts do
                                local k = parts[i]
                                if not cur[k] or type(cur[k]) ~= "table" then
                                    cur[k] = {}
                                end
                                cur = cur[k]
                            end
                            current_table = cur
                        else
                            -- Key-Value: key = value
                            local key, val = clean:match("^([%w_%-]+)%s*=%s*(.+)$")
                            if key and val then
                                if val:sub(1, 1) == "[" and not val:find("%]") then
                                    multiline_key = key
                                    multiline_buf = val
                                else
                                    current_table[key] = parse_toml_value(val)
                                end
                            end
                        end
                    end
                end
            end
        end
    end

    return result
end

local function deep_merge(a, b)
    for k, v in pairs(b) do
        if type(v) == "table" then
            if type(a[k]) == "table" then
                if #v > 0 and #a[k] > 0 then
                    for _, item in ipairs(v) do
                        table.insert(a[k], item)
                    end
                else
                    deep_merge(a[k], v)
                end
            else
                a[k] = v
            end
        else
            a[k] = v
        end
    end
end

-- -----------------------------------------------------------------------------
-- 2. Pure-Lua Mustache Engine
-- -----------------------------------------------------------------------------
local function resolve_var(key, stack, check_only_top)
    local start_idx = #stack
    local end_idx = (check_only_top and #stack > 1) and #stack or 1
    for i = start_idx, end_idx, -1 do
        local ctx = stack[i]
        if (key == "." or key == "this" or key == "path") and (type(ctx) == "string" or type(ctx) == "number") then
            return ctx
        end
        if type(ctx) == "table" then
            local val = ctx
            local found = true
            for part in key:gmatch("[^%.]+") do
                if type(val) == "table" and val[part] ~= nil then
                    val = val[part]
                else
                    found = false
                    break
                end
            end
            if found and val ~= nil then return val end
        end
    end
    return nil
end

local function is_empty(val)
    if val == nil or val == false then return true end
    if type(val) == "table" then
        if #val == 0 and next(val) == nil then return true end
    end
    if type(val) == "string" and val == "" then return true end
    return false
end

local function render_mustache(tmpl, stack)
    local pos = 1
    local out = {}

    while pos <= #tmpl do
        local t_start, t_end, tag = tmpl:find("({?%b{}})", pos)
        if not t_start then
            table.insert(out, tmpl:sub(pos))
            break
        end

        table.insert(out, tmpl:sub(pos, t_start - 1))

        if tag:sub(1, 3) == "{{{" and tag:sub(-3) == "}}}" then
            local var_name = tag:sub(4, -4):match("^%s*(.-)%s*$")
            local val = resolve_var(var_name, stack, false)
            if val ~= nil then table.insert(out, tostring(val)) end
            pos = t_end + 1
        elseif tag:sub(1, 2) == "{{" and tag:sub(-2) == "}}" then
            local inner = tag:sub(3, -3):match("^%s*(.-)%s*$")
            local tag_type = inner:sub(1, 1)

            if tag_type == "#" or tag_type == "^" then
                local sec_name = inner:sub(2):match("^%s*(.-)%s*$")
                local sec_val = resolve_var(sec_name, stack, true)
                if sec_val == nil then
                    sec_val = resolve_var(sec_name, stack, false)
                end

                local depth = 1
                local search_pos = t_end + 1
                local b_start = search_pos
                local b_end = nil

                while depth > 0 and search_pos <= #tmpl do
                    local s_s, s_e, s_tag = tmpl:find("({?%b{}})", search_pos)
                    if not s_s then break end
                    if s_tag:sub(1, 2) == "{{" and s_tag:sub(-2) == "}}" then
                        local s_inner = s_tag:sub(3, -3):match("^%s*(.-)%s*$")
                        local s_type = s_inner:sub(1, 1)
                        local s_name = s_inner:sub(2):match("^%s*(.-)%s*$")
                        if s_name == sec_name then
                            if s_type == "#" or s_type == "^" then
                                depth = depth + 1
                            elseif s_type == "/" then
                                depth = depth - 1
                                if depth == 0 then
                                    b_end = s_s - 1
                                    pos = s_e + 1
                                end
                            end
                        end
                    end
                    search_pos = s_e + 1
                end

                if b_end then
                    local block = tmpl:sub(b_start, b_end)
                    if tag_type == "#" then
                        if not is_empty(sec_val) then
                            if type(sec_val) == "table" and #sec_val > 0 then
                                for _, item in ipairs(sec_val) do
                                    table.insert(stack, item)
                                    table.insert(out, render_mustache(block, stack))
                                    table.remove(stack)
                                end
                            elseif type(sec_val) == "table" then
                                table.insert(stack, sec_val)
                                table.insert(out, render_mustache(block, stack))
                                table.remove(stack)
                            elseif sec_val == true or sec_val ~= nil then
                                table.insert(out, render_mustache(block, stack))
                            end
                        end
                    elseif tag_type == "^" then
                        if is_empty(sec_val) then
                            table.insert(out, render_mustache(block, stack))
                        end
                    end
                else
                    pos = t_end + 1
                end
            elseif tag_type == "/" then
                pos = t_end + 1
            else
                local val = resolve_var(inner, stack, false)
                if val ~= nil then table.insert(out, tostring(val)) end
                pos = t_end + 1
            end
        else
            pos = t_end + 1
        end
    end

    return table.concat(out)
end

-- -----------------------------------------------------------------------------
-- 3. Dynamic Token Discovery & Render Pipeline
-- -----------------------------------------------------------------------------
local function collect_all_token_files(custom_dir, configured_token_dirs)
    local candidate_dirs = {}
    if custom_dir then
        table.insert(candidate_dirs, custom_dir)
    elseif configured_token_dirs and #configured_token_dirs > 0 then
        for _, rel_d in ipairs(configured_token_dirs) do
            local abs_d = rel_d:sub(1,1) == "/" and rel_d or (ROOT_DIR .. "/" .. rel_d)
            if file_or_dir_exists(abs_d) then
                table.insert(candidate_dirs, abs_d)
            end
        end
    else
        local possible = {
            ROOT_DIR .. "/tokens",
            ROOT_DIR .. "/env/settings",
            ROOT_DIR .. "/env/token.db",
            ROOT_DIR .. "/env/token.kv",
            ROOT_DIR .. "/env/token",
            ROOT_DIR .. "/env/data",
            ROOT_DIR .. "/env"
        }
        for _, d in ipairs(possible) do
            if file_or_dir_exists(d) then
                table.insert(candidate_dirs, d)
            end
        end
    end

    local file_map = {}
    local files = {}

    for _, dir in ipairs(candidate_dirs) do
        local cmd = 'find -L "' .. dir .. '" -type f -name "*.toml" ! -path "*/themes/*" ! -path "*/templates/*" ! -name "shoelace.toml" ! -name "file.toml" ! -name "shoelace.config" 2>/dev/null'
        local p = io.popen(cmd)
        if p then
            for line in p:lines() do
                local fname = line:match("([^/]+%.toml)$")
                if fname and not file_map[fname] then
                    file_map[fname] = line
                    table.insert(files, line)
                end
            end
            p:close()
        end
    end

    table.sort(files)
    return files
end

local function write_file(filepath, content)
    local dir = filepath:match("(.*/)")
    if dir then
        os.execute('mkdir -p "' .. dir .. '"')
    end
    local f = io.open(filepath, "w")
    if not f then
        print("❌ Failed to write to " .. filepath)
        return false
    end
    f:write(content)
    f:close()
    return true
end

local function main()
    local custom_data_dir = nil
    for i = 1, #arg do
        if (arg[i] == "--data" or arg[i] == "-d") and arg[i+1] then
            custom_data_dir = arg[i+1]
        end
    end

    print("\27[1;36m─── Shoelace Template Renderer (Lua) ───\27[0m")

    -- 0. Load env/shoelace.toml or env/shoelace.config or env/file.toml
    local config_file = nil
    local config_candidates = {
        ROOT_DIR .. "/shoelace.toml",
        ROOT_DIR .. "/env/shoelace.toml",
        ROOT_DIR .. "/env/shoelace.config",
        ROOT_DIR .. "/env/file.toml"
    }
    for _, cfg in ipairs(config_candidates) do
        if file_or_dir_exists(cfg) then
            config_file = cfg
            break
        end
    end

    local shoelace_cfg = config_file and parse_toml_file(config_file) or {}
    local paths_cfg = shoelace_cfg.paths or {}

    local rel_templates = paths_cfg.templates_dir or (file_or_dir_exists(ROOT_DIR .. "/templates") and "templates" or "env/templates")
    local rel_config = paths_cfg.config_dir or "config"
    local templates_dir = ROOT_DIR .. "/" .. rel_templates
    local config_dir = ROOT_DIR .. "/" .. rel_config
    local token_dirs_cfg = paths_cfg.tokens_dirs

    if config_file then
        local rel_cfg_path = config_file:gsub("^" .. ROOT_DIR .. "/?", "")
        print("  \27[34mℹ\27[0m Loaded system config: " .. rel_cfg_path)
    end

    -- 1. Collect and parse all TOML tokens
    local token_data = {}
    local toml_files = collect_all_token_files(custom_data_dir, token_dirs_cfg)

    for _, file in ipairs(toml_files) do
        local rel = file:gsub("^" .. ROOT_DIR .. "/?", "")
        local parsed = parse_toml_file(file)
        if parsed then
            deep_merge(token_data, parsed)
            print("  \27[32m•\27[0m Loaded token: " .. rel)
        end
    end

    -- 2. Define / Load Template Mappings
    local mappings = {}
    for key, val in pairs(shoelace_cfg) do
        if key ~= "paths" and type(val) == "table" and #val > 0 then
            local app_name = (key == "mappings") and "" or key

            for _, entry in ipairs(val) do
                if type(entry) == "table" then
                    local entry_app = entry.app or entry.app_name or app_name
                    local t = entry.tmpl or entry.template or ""
                    local d = entry.dest or entry.destination or ""

                    if t ~= "" and d ~= "" then
                        local full_t = (entry_app ~= "" and not t:find("^" .. entry_app .. "/")) and (entry_app .. "/" .. t) or t
                        local full_d = (entry_app ~= "" and not d:find("^" .. entry_app .. "/")) and (entry_app .. "/" .. d) or d

                        table.insert(mappings, {
                            app = entry_app,
                            tmpl = full_t,
                            dest = full_d
                        })
                    end
                end
            end
        end
    end

    if #mappings == 0 then
        mappings = {
            { tmpl = "niri/appearance.kdl",   dest = "niri/sl_appearance.kdl" },
            { tmpl = "niri/colors.kdl",       dest = "niri/sl_colors.kdl" },
            { tmpl = "niri/keybinds.kdl",     dest = "niri/sl_keybinds.kdl" },
            { tmpl = "kitty/appearance.conf",  dest = "kitty/sl_appearance.conf" },
            { tmpl = "kitty/colors.conf",      dest = "kitty/sl_colors.conf" },
            { tmpl = "fuzzel/appearance.ini",  dest = "fuzzel/sl_appearance.ini" },
            { tmpl = "fuzzel/colors.ini",      dest = "fuzzel/sl_colors.ini" },
            { tmpl = "wayle/appearance.toml",  dest = "wayle/sl_appearance.toml" },
            { tmpl = "wayle/colors.toml",      dest = "wayle/sl_colors.toml" },
            { tmpl = "swaylock/config",       dest = "swaylock/sl_config" },
            { tmpl = "fish/aliases.fish",     dest = "fish/conf.d/sl_aliases.fish" },
            { tmpl = "fish/paths.fish",       dest = "fish/conf.d/sl_paths.fish" },
        }
    else
        table.sort(mappings, function(a, b) return a.tmpl < b.tmpl end)
    end

    local rendered_count = 0

    for _, m in ipairs(mappings) do
        local tmpl_path = templates_dir .. "/" .. m.tmpl
        local dest_path = config_dir .. "/" .. m.dest

        local f = io.open(tmpl_path, "r")
        if f then
            local tmpl_content = f:read("*a")
            f:close()

            local context_stack = { token_data }
            local rendered = render_mustache(tmpl_content, context_stack)

            if write_file(dest_path, rendered) then
                print(string.format("  \27[1;32m✓\27[0m Rendered: \27[1m%s\27[0m -> %s/%s", m.tmpl, rel_config, m.dest))
                rendered_count = rendered_count + 1
            end
        else
            print("  \27[33m⚠\27[0m Missing template: " .. m.tmpl .. " at " .. tmpl_path)
        end
    end

    print(string.format("\n\27[1;32m✨ Complete:\27[0m %d templates rendered successfully.\n", rendered_count))
end

main()
