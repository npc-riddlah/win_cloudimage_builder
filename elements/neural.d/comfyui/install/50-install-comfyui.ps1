logInfo "Installing ComfyUI"
loginfo "Init..."
New-Item -Path "C:\Software" -ItemType Directory
cd C:\Software
git clone https://github.com/comfyanonymous/ComfyUI.git
cd ComfyUI
python -m venv .venv
.venv\Scripts\activate
pip install torch torchvision torchaudio --extra-index-url https://download.pytorch.org/whl/cu126
pip install -r requirements.txt
deactivate
loginfo "Done!"
