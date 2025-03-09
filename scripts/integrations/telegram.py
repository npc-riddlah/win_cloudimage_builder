#TG Bot API/HTTP part
import requests, configparser
class integrator:
    def __init__(self):
        tgConfigPath = "./conf/telegram.conf"
        tgConfigFile = configparser.ConfigParser(allow_no_value=True)
        tgConfigFile.optionxform = str
        tgConfigFile.read(tgConfigPath)
        
        self.idChat=tgConfigFile['SETTINGS']['idChat']
        self.token=tgConfigFile['SETTINGS']['token']
        print("Telegram integration imported")

    def sendMsg(self,message):
        #Escaping MD chars
        message = message.replace("_", "\\_").replace("[", "\\[");
        payload = {
            'chat_id': self.idChat,
            'text': message,
            'parse_mode': 'markdown'
        }
        return requests.post(f"https://api.telegram.org/bot{self.token}/sendMessage",data=payload).json()
        
    def sendFile(self,filePath):
        payload = {
            'chat_id': self.idChat,
            'parse_mode': 'markdown'
        }
        files = {
            'document': open(filePath, 'rb')
        }
        return requests.post(f"https://api.telegram.org/bot{self.token}/sendDocument",data=payload, files=files, stream=True).json()
        