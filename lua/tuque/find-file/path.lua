-- The input is kept as the user sees it in the prompt (e.g. "~/code/tu") and only resolved when reading the disk
local path = {}

--- Like Emacs, a path pasted after the directory replaces it: "~/code//etc/" is "/etc/" and "/tmp/~/code/" is "~/code/"
--- @param input string
--- @return string
local function unshadow(input)
  local start = math.max(input:match('.*()//') or 0, input:match('.*()/~/') or 0)
  return input:sub(start + 1)
end

--- Splits the input into the directory, ending in a slash, and the query after it
--- @param input string
--- @return string directory
--- @return string query
function path.split(input)
  input = unshadow(input)
  local directory, query = input:match('^(.*/)(.*)$')
  if directory == nil then return '', input end
  return directory, query
end

--- Resolves the input to an absolute path, relative to the working directory
--- @param input string
--- @return string
function path.resolve(input) return vim.fs.abspath(vim.fs.normalize(unshadow(input))) end

--- Formats an absolute directory for the prompt, with the home directory as ~ and a trailing slash
--- @param directory string
--- @return string
function path.display_directory(directory)
  local display = vim.fn.fnamemodify(directory, ':~')
  if display:sub(-1) ~= '/' then display = display .. '/' end
  return display
end

--- @param directory string directory part of the input
--- @return string
function path.parent(directory) return path.display_directory(vim.fs.dirname(path.resolve(directory))) end

--- Typing a slash after "/" jumps to the root and after "/~" jumps home, like Emacs
--- @param input string
--- @return string | nil
function path.tidy_slash(input)
  if input:sub(-1) == '/' then return '/' end
  if input:sub(-2) == '/~' then return '~/' end
  return nil
end

return path
