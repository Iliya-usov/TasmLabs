import os   #модуль для работы с файлами
folder_name = "names"
curdir = os.getcwd() #увидим каталог, в котором мы сидим
PCI = open('PCI.txt')
max_count = 0
count = 0
temp_vid = ""
mv = ""

lastDid = ""
lastVid = ""
if(not os.path.isdir(curdir + "/" + folder_name)): #если не было папки с названием vendor id, то создаем такую
    os.mkdir(folder_name)
os.chdir(os.getcwd() + "/" + folder_name)

while True:
  line = PCI.readline() #берем строчку из файла 

  if not line: break    #если строчки кончились, то выход из цикла
 
  if line[0] != "\"" or line[7] != "\"":
   continue 
  if line[11] != "x":
    continue
  if line[9] != "\"" or line[16] != "\"":
    continue

  vid = ""
  for i in range(3, 7): #в этих символах будет vendor id
    vid = vid + line[i]

  if(not os.path.isdir(os.getcwd() + "/" + vid)): 
    os.mkdir(vid)
  os.chdir(os.getcwd() + "/" + vid)

  did = ""
  for i in range(12,16):
    did = did + line[i]
  did = did.upper()

  if vid < lastVid or vid==lastVid and did <= lastDid:
    lastDid = did
    lastVid = vid
    os.chdir(curdir + "/" + folder_name)
    continue
  lastDid = did
  lastVid = vid

  did_file = open(did + ".txt", "w+")
  did_file.write(line[18:len(line)-2].upper() + "\r\n$")

  did_file.close()
  os.chdir(curdir + "/" + folder_name)
PCI.close()
    

