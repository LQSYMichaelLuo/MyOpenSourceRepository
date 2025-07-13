fileUtil = {
  ["NAME"]="FileUtil",
  ["author"]="Michael Luo",
  ["version"]=3
}
function tohex(value)
  local hex = ''
  while value > 0 do
    local index = math.fmod(value, 16) + 1
    value = math.floor(value / 16)
    hex = string.sub('0123456789abcdef', index, index) .. hex
  end
  return hex == '' and '00' or hex
end
function fileUtil.new(road)
  local object = {}
  local self = {}
  local id = math.random(0x0, 0xFFFFFF)
  object.__index = object
  object.__name = "FileUtilObject"
  object.__tostring = function()
    return road
  end
  object.__type = function()
    return 'core.lqsy.utils.fileUtil$Object['.. tohex(id) ..']'
  end
  setmetatable(object, {__index=fileUtil,
    __tostring=object.__tostring,
    __type=object.__type,
  })
  if road.road road = road.road end
  assert(type(road) == "string","you have used an incorrect syntax (you should create an object for 'fileUtil.new(string)' or 'File(string)' instead of 'fileUtil(string)' ).")
  local theLastCharacterOfPathString = string.sub(road,#road,#road)
  if theLastCharacterOfPathString == "/" then
    road = road:match"(.+)/" or ""
  end
  object.road = road
  assert(type(object.road)=="string","bad argument #1 to 'new' (string expected got "..type(object.road)..")")
  return object
end
function fileUtil:getPath()
  return self.road
end
function fileUtil:getName()
  return string.match(self.road, "([^/]+)$")
end
function fileUtil:getParentFile()
  local parentPath = string.match(self.road, "(.*)/") or ""
  if #parentPath < 1
    parentPath = "/"
  end
  return File(parentPath)
end
function fileUtil:getParent()
  local parentPath = string.match(self.road, "(.*)/") or ""
  if #parentPath < 1
    parentPath = "/"
  end
  return parentPath
end
function sort(table)
  for a=1,#table
    for i=1,#table-a do
      if string.upper(table[i])>string.upper(table[i+1]) then
        local num=table[i+1]
        table[i+1]=table[i]
        table[i]=num
      end
    end
  end
  return table
end
function fileUtil:moveTo(road)
  if road.road road = road.road end
  local state, errorCode = os.rename (self.road, road)
  if !state
    return errorCode, self
   else
    --return self, true
  end
end
function fileUtil:renameTo(name)
  if name.road self:moveTo(name.road)
   elseif File(name):exists() self:moveTo(name)
   else
    self:moveTo(self:getParent().."/"..name)
  end
end
function fileUtil:copyTo(road)
  if road.road road = road.road end
  if File(road):exists() road = File(road):getParent() end
  local status, command, code = os.execute("cp -r "..self.road.." "..road)
  if !status return 'failed to copy the file or the directory', self
   else --return status
  end
end
function fileUtil:delete()
  local status, command, code = os.execute('rm -r '.. self.road)
  if !status return 'failed to delete the file or the directory', self
   else self:destroy() return status
  end
end
function fileUtil:mkdir(name)
  local status, command, code = os.execute('mkdir '.. self.road.."/"..name)
  if !status return 'the directory name you input is incorrect', self
   else return status
  end
end
function fileUtil:mkdirs(arg)
  local path = self.road
  assert(type(arg)=="table","bad argument #1 to 'mkdirs' (table expected got "..type(arg)..")")
  for key, value in ipairs(arg)
    local File = File(path)
    File:mkdir(value)
    path = path .."/".. value
  end
  return true
end
function fileUtil:exists()
  local f=io.open(self.road,'r')
  if f~=nil
    io.close(f)
    return true, self
   else
    return false
  end
end
function fileUtil:length()
  return io.info(self.road).size
end
function fileUtil:getCreateTime()
  return io.info(self.road).atime
end
function fileUtil:getLastModifiedTime()
  return io.info(self.road).mtime
end
function fileUtil:createNewFile(name)
  local filePath = self.road .. "/" ..name
  if File(filePath):exists()
    return "the file already exists", self
   elseif name:match("/")
    return "the file can't be created, please change the file name and try again", self
   else
    local createFile = function()
      io.open(self.road.."/"..name,"w"):close()
    end
    if pcall(createFile)
      createFile()
      return self, true
     else
      return "failed to create the file", self
    end
  end
end
function fileUtil:toJavaObject()
  local road = self.road
  local mObject = luajava.bindClass("java.io.File")(road)
  self:destroy()
  return mObject
end
function fileUtil:read()
  if self:isFile() then
    local mObject = io.popen("cd "..self:getParent().."\n cat "..self:getName())
    local mText = mObject:read("*a")
    mObject:close()
    return mText
  end
end
function fileUtil:listAsFileList()
  if self:isDirectory() then
    local mObject = io.popen("cd "..self.road.."\n find . ")
    local mText = mObject:read("*a")
    mObject:close()
    return mText
  end
end
function fileUtil:listAsFilesObjectsList()
  local mList = self:listObjects(true)
  local mFileList = {}
  local function getFileTable(mList)
    for i = 1, #mList do
      local SubObject = mList[i]
      if SubObject:isFile()
        mFileList[#mFileList+1] = SubObject
       elseif SubObject:isDirectory()
        getFileTable(SubObject:listObjects(true))
      end
    end
  end
  getFileTable(mList)
  return mFileList
end
function fileUtil:changeDirectory(arg)
switch type(arg) do
   case "string"
    local arg = File(arg)
    if arg:isDirectory() then
      self:destroy()
      return arg
     else
      return "failed to change directory", self
    end
   case "FileUtilObject"
    self:destroy()
    return arg
  end
  if self:isDirectory()
    self:destroy()
    return arg
   else
    return "failed to change directory", self
  end
end
function fileUtil:openFile(mode)
  if self:isFile()
    return io.open(self.road,mode)
   else
    return "failed to open the file", self
  end
end
function fileUtil:isDirectory()
  return io.isdir(self.road)
end
function fileUtil:isFile()
  local isFile = io.open(self.road, "r") ~= nil
  if isFile
    if io.isdir(self.road)
      return false
     else
      return true
    end
   else
    return false
  end
end
function fileUtil:toObject(path)
  return fileUtil.new(path)
end
function fileUtil:listFiles(boolean)
  if self:isDirectory() then
    local fileTable = io.ls(self.road)
    local FileTable = {}
    if !fileTable return self,{} end
    for key, value in ipairs(fileTable)
      if ((value == ".") or (value == ".."))
       else
        FileTable[#FileTable+1] = self.road.."/"..value
      end
    end
    if boolean
      return sort(FileTable)
     else
      return FileTable
    end
   else
    return {self.road}
  end
end
function fileUtil:listObjects(boolean)
  if self:isDirectory() then
    local fileTable = io.ls(self.road)
    local FileTable = {}
    if !fileTable return {} end
    for key, value in ipairs(fileTable)
      if ((value == ".") or (value == ".."))
       else
        FileTable[#FileTable+1] = (self.road.."/"..value)
      end
    end
    if boolean
      local FileTable = sort(FileTable)
      for i = 1, #FileTable
        FileTable[i]=File(FileTable[i])
      end
      return FileTable
     else
      for i = 1, #FileTable
        FileTable[i]=File(FileTable[i])
      end
      return FileTable
    end
   else
    return {File(self.road)}
  end
end
function fileUtil:list(boolean)
  if self:isDirectory() then
    local fileTable = io.ls(self.road)
    local FileTable = {}
    if !fileTable return {} end
    for key, value in ipairs(fileTable)
      if ((value == ".") or (value == ".."))
       else
        FileTable[#FileTable+1] = value
      end
    end
    if boolean
      return self, sort(FileTable)
     else
      return FileTable
    end
   else
    return {self:getName()}
  end
end
function fileUtil:destroy()
  setmetatable(self,{__index=nil,road=nil})
  self = nil
  collectgarbage("collect")
  return true
end
function File(path)
  return fileUtil.new(path)
end
fileUtil.__call=File
setmetatable(fileUtil,fileUtil)