#General Vars
$InstallationFolder = "C:\ChatWithRTX\"
$InstallationTmp = "C:\ChatWithRTX\tmp\"
$SubPackageDirectory = "C:\tools\chatwithrtx\RAG\"

#RAG Vars
$MiniCondaPath = $InstallationFolder + "MiniConda"
$MinicondaEnv = "env_nvd_rag"
$MinicondaEnvPath = $InstallationFolder + $MinicondaEnv
$MiniConda_Installer = "Miniconda3-latest-Windows-x86_64.exe"
$MiniConda_URL = "https://repo.anaconda.com/miniconda/$MiniConda_Installer"
$MiniConda_InstallerPath = $InstallationTmp + $MiniConda_Installer

$TrtLLM_URL = "https://github.com/NVIDIA/TensorRT-LLM/archive/refs/tags/v0.7.0.zip"
$TrtLLM_FileName = "TensorRT-LLM-0.7.0"
$TrtLLM_ZIP = $TrtLLM_FileName+".zip"
$TrtLLM_ZIPPath = $InstallationTmp + $TrtLLM_ZIP

$RAG_URL = "https://github.com/NVIDIA/trt-llm-rag-windows/archive/refs/heads/release/1.0.zip"
$RAG_FileName = "trt-llm-rag-windows-main"
$RAG_ZIP = $RAG_FileName + ".zip"
$RAG_ZIPPath = $SubPackageDirectory + $RAG_ZIP

$MSMPI_URL = "https://github.com/microsoft/Microsoft-MPI/releases/download/v10.1.1/msmpisetup.exe"
$MSMPI_Installer = "msmpisetup.exe"
$MSMPI_InstallerPath = $InstallationTmp + $MSMPI_Installer

$TrtLLMExtractionPath = "$InstallationFolder\TensorRT-LLM"
$RagExtractionPath = "$InstallationFolder\RAG"
$RagModelDirectory = "$RagExtractionPath\$RAG_FileName\model"
$MiniCondaActivateCmd = "call $MiniCondaPath\Scripts\activate.bat "
$MiniCondaEnvActivate = "$MiniCondaActivateCmd $MinicondaEnvPath "
$Rag_PIPCmd = "pip install -r $RagExtractionPath\$RAG_FileName\requirements.txt --extra-index-url https://download.pytorch.org/whl/nightly/cu121"
$TrtLLM_PIPCmd = "pip install tensorrt_llm==0.7.0 --extra-index-url https://pypi.nvidia.com --extra-index-url https://download.pytorch.org/whl/cu121"
$Torch_PIPCmd = "pip install torch==2.1.0+cu121 --extra-index-url https://pypi.nvidia.com --extra-index-url https://download.pytorch.org/whl/nightly/cu121 --extra-index-url https://download.pytorch.org/whl/cu121"
$Cudnn_PIPCmd = "pip install nvidia-cudnn-cu11==8.9.4.25 --no-cache-dir"
$Tensor_PIPCmd = "pip install --pre --extra-index-url https://pypi.nvidia.com/ tensorrt==9.2.0.post12.dev5 --no-cache-dir"

#Llama13b Vars
$llamaWeightsBaseDownloadUrl = "https://api.ngc.nvidia.com/v2/models/org/nvidia/llama2-13b/1.3/files?redirect=true&path="
$llamaWeightsBaseDownloadPath = "$RagModelDirectory\llama\llama13_int4_awq_weights"
$llamaHfWeightsBasePath = "$RagModelDirectory\llama\llama13_hf"
$EngineFileName = "llama_float16_tp1_rank0.engine"
$EngineFilePath = "$RagModelDirectory\llama\llama13_int4_engine\$EngineFileName"
$TrtEngineBuildCmd = "$MiniCondaEnvActivate & python.exe '$TrtLLMExtractionPath\$TrtLLM_FileName\examples\llama\build.py' --model_dir '$RagModelDirectory\llama\llama13_hf' --quant_ckpt_path '$RagModelDirectory\llama\llama13_int4_awq_weights\llama_tp1_rank0.npz' --dtype float16 --remove_input_padding --use_gpt_attention_plugin float16 --enable_context_fmha --use_gemm_plugin float16 --use_weight_only --weight_only_precision int4_awq --per_group --output_dir '$RagModelDirectory\llama\llama13_int4_engine' --world_size 1 --tp_size 1 --parallel_build --max_input_len 3900 --max_batch_size 1 --max_output_len 1024"
$ModelTokenBaseUrl = "https://huggingface.co/TheBloke/Llama-2-13B-chat-AWQ/resolve/main/"
$ModelTokenizerList = "config.json##tokenizer.json##tokenizer.model##tokenizer_config.json"


#=======General Init=======
Add-Type -AssemblyName System.IO.Compression.FileSystem
New-Item $InstallationFolder -ItemType Directory -ea 0
New-Item $InstallationTmp -ItemType Directory -ea 0

#=======Installing RAG=======
	#Downloading necessary files
#Invoke-WebRequest $RAG_URL -OutFile $RAG_ZIPPath
Invoke-WebRequest $TrtLLM_URL -OutFile $TrtLLM_ZIPPath
Invoke-WebRequest $MiniConda_URL -OutFile $MiniConda_InstallerPath
Invoke-WebRequest $MSMPI_URL -OutFile $MSMPI_InstallerPath
	#Extracting downloaded artifacts
Expand-Archive -LiteralPath $TrtLLM_ZIPPath -DestinationPath $TrtLLMExtractionPath -Force
Expand-Archive -LiteralPath $RAG_ZIPPath -DestinationPath $RagExtractionPath -Force
	#Installing and configuring

$job_MSMPI = Start-Job {& $MSMPI_InstallerPath -unattend}
Start-Process -FilePath $MSMPI_InstallerPath -ArgumentList "-unattend" -Wait
Start-Process -FilePath $MiniConda_InstallerPath -ArgumentList "/AddToPath=0 /RegisterPython=0 /S /D=$MiniCondaPath" -Wait
Start-Process -FilePath $MiniCondaPath\Scripts\conda.exe -ArgumentList "create -p $MinicondaEnvPath python=3.10 -y" -Wait
Start-Process -FilePath $MiniCondaPath\Scripts\conda.exe -ArgumentList "config --set channel_priority strict" -Wait
Start-Process -FilePath $MiniCondaPath\Scripts\conda.exe -ArgumentList "install -p $MinicondaEnvPath -c nvidia/label/cuda-12.2.1 cuda-toolkit -y" -Wait

$env:path += "$MinicondaEnvPath\Lib\site-packages\torch\lib"

Add-Content -Path $InstallationTmp\pipinstall.cmd -Value $MiniCondaEnvActivate
Add-Content -Path $InstallationTmp\pipinstall.cmd -Value $Rag_PIPCmd
Add-Content -Path $InstallationTmp\pipinstall.cmd -Value $Torch_PIPCmd
Add-Content -Path $InstallationTmp\pipinstall.cmd -Value $Cudnn_PIPCmd
Add-Content -Path $InstallationTmp\pipinstall.cmd -Value $Tensor_PIPCmd
Add-Content -Path $InstallationTmp\pipinstall.cmd -Value $TrtLLM_PIPCmd
Add-Content -Path $InstallationTmp\pipinstall.cmd -Value "exit"
& $InstallationTmp\pipinstall.cmd

	#Cleaning
Remove-Item $InstallationTmp\pipinstall.cmd
Remove-Item $MiniConda_InstallerPath
Remove-Item $MSMPI_InstallerPath
Remove-Item $TrtLLM_ZIPPath
Remove-Item $RAG_ZIPPath

	#Creating Shortcut
Move-Item -Path $SubPackageDirectory\icon.ico -Destination $InstallationFolder\RAG\$RAG_FileName\icon.ico
$WshShell = New-Object -comObject WScript.Shell
$Shortcut = $WshShell.CreateShortcut("C:\Users\Public\Desktop\ChatWithRTX.lnk")
$Shortcut.TargetPath = $InstallationFolder + "\RAG\"+$RAG_FileName+"\app_launch.bat"
$Shortcut.IconLocation = $InstallationFolder + "\RAG\"+$RAG_FileName+"\icon.ico"
$Shortcut.WorkingDirectory = $InstallationFolder + "\RAG\"+$RAG_FileName
$Shortcut.Save()


#=======Llama13B=======
	#Creating dirs
New-Item $llamaHfWeightsBasePath -ItemType Directory -ea 0
New-Item $llamaWeightsBaseDownloadPath -ItemType Directory -ea 0
	#Installing llama model
Move-Item -Path $SubPackageDirectory\llama\llama13_int4_awq_weights\llama_tp1.json -Destination $llamaWeightsBaseDownloadPath\llama_tp1.json
Move-Item -Path $SubPackageDirectory\llama\llama13_int4_awq_weights\llama_tp1_rank0.npz -Destination $llamaWeightsBaseDownloadPath\llama_tp1_rank0.npz
Move-Item -Path $SubPackageDirectory\llama\llama13_hf\config.json -Destination $llamaHfWeightsBasePath\config.json
Move-Item -Path $SubPackageDirectory\llama\llama13_hf\tokenizer.json -Destination $llamaHfWeightsBasePath\tokenizer.json
Move-Item -Path $SubPackageDirectory\llama\llama13_hf\tokenizer.model -Destination $llamaHfWeightsBasePath\tokenizer.model
Move-Item -Path $SubPackageDirectory\llama\llama13_hf\tokenizer_config.json -Destination $llamaHfWeightsBasePath\tokenizer_config.json
Move-Item -Path $SubPackageDirectory\llama\llama_license.txt -Destination $RagModelDirectory\llama\llama_license.txt

Add-Content -Path $InstallationTmp\pipinstall.cmd -Value $TrtEngineBuildCmd
& $InstallationTmp\pipinstall.cmd
Remove-Item $InstallationTmp\pipinstall.cmd

#======Mistral======
	#EnvVars
$MistralWeightsBaseDownloadUrl = "https://api.ngc.nvidia.com/v2/models/org/nvidia/mistral-7b-int4-chat/1.0/files?redirect=true&path="
$MistralWeightsBaseDownloadPath = "$RagModelDirectory\mistral\mistral7b_int4_quant_weights"
$MistralHfWeightsBasePath = "$RagModelDirectory\mistral\mistral7b_hf"
$EngineFileName = "llama_float16_tp1_rank0.engine"
$EngineFilePath = "$RagModelDirectory\mistral\mistral7b_int4_engine\$EngineFileName"
$TrtEngineBuildCmd = "$MiniCondaEnvActivate && python.exe '$TrtLLMExtractionPath\$TrtLLM_FileName\examples\llama\build.py' --model_dir '$MistralHfWeightsBasePath' --quant_ckpt_path '$MistralWeightsBaseDownloadPath\mistral_tp1_rank0.npz' --dtype float16 --remove_input_padding --use_gpt_attention_plugin float16 --enable_context_fmha --use_gemm_plugin float16 --use_weight_only --weight_only_precision int4_awq --per_group --output_dir '$RagModelDirectory\mistral\mistral7b_int4_engine' --world_size 1 --tp_size 1 --parallel_build --max_input_len 7168 --max_batch_size 1 --max_output_len 1024"
$ModelTokenBaseUrl = "https://huggingface.co/mistralai/Mistral-7B-Instruct-v0.1/resolve/main/"
$ModelTokenizerList = "config.json##generation_config.json##special_tokens_map.json##tokenizer.json##tokenizer.model##tokenizer_config.json"

	#Creating dirs
New-Item $MistralHfWeightsBasePath -ItemType Directory -ea 0
New-Item $MistralWeightsBaseDownloadPath -ItemType Directory -ea 0
	#Installing Mistral8 Model
Move-Item -Path $SubPackageDirectory\mistral\mistral7b_int4_quant_weights\mistral_tp1_rank0.npz -Destination $MistralWeightsBaseDownloadPath\mistral_tp1_rank0.npz
Move-Item -Path $SubPackageDirectory\mistral\mistral7b_int4_quant_weights\mistral_tp1.json -Destination $MistralWeightsBaseDownloadPath\mistral_tp1.json
Move-Item -Path $SubPackageDirectory\mistral\mistral7b_hf\config.json -Destination $MistralHfWeightsBasePath\config.json
Move-Item -Path $SubPackageDirectory\mistral\mistral7b_hf\tokenizer.json -Destination $MistralHfWeightsBasePath\tokenizer.json
Move-Item -Path $SubPackageDirectory\mistral\mistral7b_hf\tokenizer.model -Destination $MistralHfWeightsBasePath\tokenizer.model
Move-Item -Path $SubPackageDirectory\mistral\mistral7b_hf\tokenizer_config.json -Destination $MistralHfWeightsBasePath\tokenizer_config.json
Move-Item -Path $SubPackageDirectory\mistral\mistral_license.txt -Destination $RagModelDirectory\mistral\mistral_license.txt

Add-Content -Path $InstallationTmp\pipinstall.cmd -Value $TrtEngineBuildCmd
& $InstallationTmp\pipinstall.cmd
Remove-Item $InstallationTmp\pipinstall.cmd

Remove-Item -Force $PSCommandPath
Remove-Item -LiteralPath C:\tools\chatwithrtx -Force -Recurse
exit

