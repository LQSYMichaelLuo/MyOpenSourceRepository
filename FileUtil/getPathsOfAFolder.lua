--MIT License
--Author: MichaelLuo

--导入所需库
require("import")
import("java.io.File")

--获取某目录路径下所有文件的绝对路径
--@parameter:
--basicPath string 
--@return:
--absolutePathsTable table 
function getTheAbsolutePathsTableOfAllFilesUnderThePath(basicPath)
  local absolutePathsTable = {}
  local fileBasicPath = File(basicPath)
  if fileBasicPath.isDirectory() then
    local tab = fileBasicPath.listFiles()
    for i = 0, #tab - 1 do
      local userdata = tab[i]
      if userdata.isDirectory() then
        local absolutePathsTable_child = getTheAbsolutePathsTableOfAllFilesUnderThePath(tostring(userdata))
        for i = 1, #absolutePathsTable_child do
          absolutePathsTable[#absolutePathsTable+1] = absolutePathsTable_child[i]
        end
      else
        absolutePathsTable[#absolutePathsTable+1] = tostring(userdata)
      end
      luajava.clear(userdata)
    end
    luajava.clear(fileBasicPath)
    return absolutePathsTable
  else
    return {basicPath}
  end
end

--获取某目录路径下所有文件的相对路径
--@parameter:
--path string 
--@return:
--relativePathsTable table 
function getTheRelativePathsTableOfAllFilesUnderThePath(path)
  local userdata = File(path)
  local path = tostring(userdata) .. "/"
  if userdata.isDirectory() then
    luajava.clear(userdata)
    local relativePathsTable = {}
    local absolutePathsTable = getTheAbsolutePathsTableOfAllFilesUnderThePath(path)
    for i = 1, #absolutePathsTable do
      relativePathsTable[#relativePathsTable+1] = absolutePathsTable[i]:match(path.."(.+)")
    end
    return relativePathsTable
  else
    return {userdata.getName()}
  end
end

--使用示例：
local path = "/storage/emulated/0/Androlua/"
local relativePaths = getTheRelativePathsTableOfAllFilesUnderThePath(path)
local absolutePaths = getTheAbsolutePathsTableOfAllFilesUnderThePath(path)
print("以下是" .. path .. "下所有文件的相对路径列表" .. dump(relativePaths))
print("以下是" .. path .. "下所有文件的绝对路径列表" .. dump(absolutePaths))
