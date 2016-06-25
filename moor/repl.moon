ln = require'linenoise'
import remove, insert, concat from table
import printerr, to_lua, evalprint from require'moor.utils'

prompt =
	p: ">"
	deepen: => @p = "? "
	reset: => @p = ">"

---- tab completion
cndgen = (env) ->  (line) ->
	if i1 = line\find '[.\\%w_]+$' -- if completable
		with res = {}
			front = line\sub(1, i1 - 1)
			partial = line\sub i1
			prefix, last = partial\match '(.-)([^.\\]*)$'
			t, all = env

			if #prefix > 0 -- tbl.ky or not
				P = prefix\sub(1, -2)
				all = last == ''

				for w in P\gmatch '[^.\\]+'
					t = t[w]

					return unless t

			prefix = front .. prefix

			append_candidates = (t) ->
				if type(t) == 'table'
					table.insert(res, prefix .. k) for k in pairs t when all or k\sub(1, #last) == last

			append_candidates t

			if mt = getmetatable t then append_candidates mt.__index

compgen = (env) ->
	candidates = cndgen env

	(c, s) -> if cc = candidates s
		ln.addcompletion c, name for name in *cc

string.match_if_fncls = =>
	@\match"[-=]>$" or
	@\match"class%s*$" or
	@\match"class%s+%w+$" or
	@\match"class%s+extends%s+%w+%s*$" or
	@\match"class%s+%w+%s+extends%s+%w+%s*$"

-- for busted unit test, repl is sepalated with `get_line` and `replgen`
-- and using the former for the test, the latter is only needed by `repl`.

get_line = ->
	with line = ln.linenoise prompt.p .. " "
		if line and line\match '%S' then ln.historyadd line

replgen = (get_line) -> (env = {}, _ENV = _ENV) ->
	block = {}

	ln.setcompletion compgen _ENV

	while true
		line = get_line!

		unless line then break
		elseif #line < 1 then continue

		-- if line\match"^:"
			-- (require'moor.replcmd') line
			-- continue

		is_fncls, lua_code, err =  if line\match_if_fncls!
			true
		else
			false, to_lua line

		if lua_code and not err
			evalprint env, lua_code
		elseif is_fncls or err\match "^Failed to parse"
			insert block, line

			prompt.reset with prompt
				\deepen!
				while line and #line > 0
					line = get_line!
					insert block, " #{line}"

			lua_code, err = to_lua concat block, "\n"

			if lua_code then evalprint env, lua_code

			block = {}

		if err
			printerr err

	env

-- this is main repl
repl = replgen get_line

setmetatable {:replgen, :repl, :printerr}, __call: (env, _ENV) => repl env, _ENV

