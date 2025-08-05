local tArgs = {...}
local scanner = {}

---use a scanlist.lua file to define a list of block ids to scan for
local ok,result = pcall(require,"scanlist")
scanner.scanlist = ok and result or {}

---the range to scan within
---@type 0|1|2|3|4|5|6|7|8|9|10|11|12|13|14|15|16
scanner.range = 8

---@class Vein
---@field blockInfo ccTweaked.turtle.inspectInfo the block info for the vein
---@field count integer how many blocks are in the vein

local function checkList(id)
  for _,v in ipairs(scanner.scanlist) do
    if id == v then return true end
  end
  return false
end

local function filter(blocks)
  local filtered = {}
  local count = 1
  for _,v in ipairs(blocks) do
    if checkList(v.name) then
      filtered[count] = v
      count = count+1
    end
  end
  return filtered
end

local function checkPos(pivot,block)
  if not (pivot.x == block.x and pivot.y == block.y and pivot.z == block.z)
    and block.x > pivot.x-2 and block.x < pivot.x+2
    and block.y > pivot.y-2 and block.y < pivot.y+2
    and block.z > pivot.z-2 and block.z < pivot.z+2
  then
    return true
  end
  return false
end

local function removeNeighbors(pivot,unseen)
  for i,v in ipairs(unseen) do
    if v == pivot.blockInfo then
      table.remove(unseen,i)
    end
  end
  for _,v in ipairs(unseen) do
    if checkPos(pivot.blockInfo,v) and v.name == pivot.blockInfo.name then
      pivot.count = pivot.count + 1
      pivot.blockInfo = v
      removeNeighbors(pivot,unseen)
    end
  end
end

local function getVeins(unseen)
  local veins = {}
  while #unseen > 0 do
    local v = {blockInfo = unseen[1],count = 1}
    table.insert(veins,v)
    removeNeighbors(v,unseen)
  end
  return veins
end

---scan the area for blocks on the scanlist.lua
---@return Vein[]
function scanner.scan()
  local geo = peripheral.find("geo_scanner")
  ---@diagnostic disable-next-line
  return getVeins(filter(geo.scan(8)))
end
return scanner
