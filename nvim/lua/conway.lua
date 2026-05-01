-- Conway's Game of Life seeded with hand-picked methuselahs.
-- Each lives 100s-1000s of generations and naturally spawns gliders.
-- Sim space is independent of viewport: sim grows monotonically on resize,
-- viewport is centered crop. Shrinking the window only clips the view.

local DELAY, CYCLE = 120, 600

local METHUSELAHS = {
  { ".XX", "XX.", ".X." },                -- R-pentomino
  { ".X.....", "...X...", "XX..XXX" },    -- Acorn
  { "......X.", "XX......", ".X...XXX" }, -- Diehard
  { "XXX", "X.X", "X.X" },                -- Pi-heptomino
  { ".XXX", "XXX.", "..X." },             -- B-heptomino
}

local function blank(w, h)
  local g = {}
  for r = 1, h do
    g[r] = {}
    for c = 1, w do g[r][c] = 0 end
  end
  return g
end

local function stamp(g, w, h, pat, row, col, flip)
  for r, line in ipairs(pat) do
    for c = 1, #line do
      local idx = flip and (#line - c + 1) or c
      local ch = line:sub(idx, idx)
      local rr, cc = row + r - 1, col + c - 1
      if rr >= 1 and rr <= h and cc >= 1 and cc <= w and ch == "X" then
        g[rr][cc] = 1
      end
    end
  end
end

local function seed_methuselahs(g, w, h)
  for r = 1, h do for c = 1, w do g[r][c] = 0 end end
  local n = math.max(3, math.floor((w * h) / 350))
  for _ = 1, n do
    local pat = METHUSELAHS[math.random(#METHUSELAHS)]
    local ph, pw = #pat, #pat[1]
    if h > ph + 4 and w > pw + 4 then
      local row = math.random(3, h - ph - 2)
      local col = math.random(3, w - pw - 2)
      stamp(g, w, h, pat, row, col, math.random() < 0.5)
    end
  end
end

local function step(g, w, h)
  local n = blank(w, h)
  for r = 1, h do
    for c = 1, w do
      local count = 0
      for dr = -1, 1 do
        for dc = -1, 1 do
          if dr ~= 0 or dc ~= 0 then
            local rr, cc = r + dr, c + dc
            if rr >= 1 and rr <= h and cc >= 1 and cc <= w then
              count = count + g[rr][cc]
            end
          end
        end
      end
      local alive = g[r][c] == 1
      if alive and (count == 2 or count == 3) then n[r][c] = 1
      elseif (not alive) and count == 3 then n[r][c] = 1 end
    end
  end
  return n
end

-- Project sim grid (sw x sh) onto viewport (vw x vh), centered.
local function project(g, sw, sh, vw, vh)
  local ox = math.floor((sw - vw) / 2)
  local oy = math.floor((sh - vh) / 2)
  local lines = {}
  for r = 1, vh do
    local s = {}
    local row = g[oy + r]
    for c = 1, vw do
      local v = row and row[ox + c]
      s[c] = v == 1 and "#" or " "
    end
    lines[r] = table.concat(s)
  end
  return lines
end

local function hash(g, sw, sh)
  local rows = {}
  for r = 1, sh do
    local s = {}
    for c = 1, sw do s[c] = g[r][c] == 1 and "1" or "0" end
    rows[r] = table.concat(s)
  end
  return table.concat(rows, "\n")
end

local function render(buf, grid, sw, sh, vw, vh)
  if not vim.api.nvim_buf_is_valid(buf) then return end
  vim.bo[buf].modifiable = true
  local cw, ch = math.max(0, vw - 2), math.max(0, vh - 2)
  local content = project(grid, sw, sh, cw, ch)
  local lines = { "" }
  for _, l in ipairs(content) do lines[#lines + 1] = " " .. l end
  pcall(vim.api.nvim_buf_set_lines, buf, 0, -1, false, lines)
  vim.bo[buf].modifiable = false
  vim.bo[buf].modified = false
end

vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    if vim.fn.argc() > 0 then return end
    math.randomseed(os.time())
    local buf = vim.api.nvim_get_current_buf()
    local win = vim.api.nvim_get_current_win()
    vim.bo[buf].buftype = "nofile"
    vim.bo[buf].bufhidden = "wipe"
    local saved = {
      number = vim.wo[win].number,
      relativenumber = vim.wo[win].relativenumber,
      signcolumn = vim.wo[win].signcolumn,
      fillchars = vim.wo[win].fillchars,
      wrap = vim.wo[win].wrap,
    }
    vim.wo[win].number = false
    vim.wo[win].relativenumber = false
    vim.wo[win].signcolumn = "no"
    vim.wo[win].fillchars = "eob: "
    vim.wo[win].wrap = false
    vim.api.nvim_create_autocmd("BufWinLeave", {
      buffer = buf,
      once = true,
      callback = function()
        if not vim.api.nvim_win_is_valid(win) then return end
        for k, v in pairs(saved) do vim.wo[win][k] = v end
      end,
    })

    local W = vim.api.nvim_win_get_width(win)
    local H = vim.api.nvim_win_get_height(win)
    local SW, SH = W, H
    local grid = blank(SW, SH)
    seed_methuselahs(grid, SW, SH)
    local gen, history = 0, {}

    vim.api.nvim_create_autocmd("VimResized", {
      callback = function()
        if not vim.api.nvim_win_is_valid(win) then return true end
        W = vim.api.nvim_win_get_width(win)
        H = vim.api.nvim_win_get_height(win)
        if W > SW or H > SH then
          local nSW, nSH = math.max(SW, W), math.max(SH, H)
          local n = blank(nSW, nSH)
          local ox = math.floor((nSW - SW) / 2)
          local oy = math.floor((nSH - SH) / 2)
          for r = 1, SH do
            for c = 1, SW do n[oy + r][ox + c] = grid[r][c] end
          end
          grid, SW, SH = n, nSW, nSH
          history = {}
        end
        render(buf, grid, SW, SH, W, H)
      end,
    })

    local function loop()
      if not vim.api.nvim_buf_is_valid(buf) then return end
      render(buf, grid, SW, SH, W, H)
      gen = gen + 1
      local h = hash(grid, SW, SH)
      local stalled = history[h] ~= nil
      history[h] = true
      if gen >= CYCLE or stalled then
        seed_methuselahs(grid, SW, SH)
        gen, history = 0, {}
      else
        grid = step(grid, SW, SH)
      end
      vim.defer_fn(loop, DELAY)
    end
    loop()
  end,
})
