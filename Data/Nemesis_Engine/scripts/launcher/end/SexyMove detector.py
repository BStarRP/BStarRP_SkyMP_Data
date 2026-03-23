from pathlib import Path
import shutil

my_file = Path("../FNISSexyMove.esp")

if my_file.is_file():
	fnis = Path("../FNIS.esp")
	
	if fnis.is_file():
		file = Path("../../binkw32.dll")
		dst = '../FNIS.esp'
		
		if file.is_file():
			shutil.copy2('scripts/launcher/end/XPMSE/fnis', dst)
		else:
			shutil.copy2('scripts/launcher/end/XPMSE/fnis_sse', dst)
		
	fnis = Path("../scripts/FNIS.pex")
	
	if fnis.is_file():
		# create FNIS version, allowing FNIS based mods hook to a proxy
		shutil.copy2('scripts/launcher/end/SexyMove/script', '../scripts/FNIS.pex')

