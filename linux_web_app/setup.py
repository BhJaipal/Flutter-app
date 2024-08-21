import os
import shutil
import time

try:
	with open("com.flutter.WebApps.desktop", "r+") as file:
		content = file.read()
		content = content.replace("$curr", os.getcwd())
		content = content.replace("$home", os.environ["HOME"])

		file.seek(0)
		file.write(content)
		shutil.copyfile("web_apps.svg", os.environ["HOME"]+ "/.var/app/com.flutter.WebApps/web_apps.svg")
		time.sleep(1)
		shutil.copyfile("com.flutter.WebApps.desktop", os.environ["HOME"]+ "/.local/share/applications/com.flutter.WebApps.desktop")
except Exception as e:
	print("\033[0;31mSetup failed!\033[0m")
	print(e)
else:
	print("\033[0;32mSetup completed!\033[0m")