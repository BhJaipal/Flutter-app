import os
import shutil
import time

try:
    with open("lib/db_helper.dart", "r+") as file:
        content = file.read()
        content = content.replace("|curr|", os.getcwd())
        file.seek(0)
        file.write(content)
except Exception as e:
	print("\033[0;31mSetup failed!\033[0m")
	print(e)
else:
	print("\033[0;32mSetup completed!\033[0m")
