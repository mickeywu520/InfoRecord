# DeepX SDK (DXRT: 3.2.0 / driver: 2.1.0)

### setup env.
```
/dx-all-suite/dx-runtime/install.sh --all
```
- dx-all-suite
```
https://github.com/DEEPX-AI/dx-all-suite
```
- dx-runtime, default is empty in dx-all-suite project
```
https://github.com/DEEPX-AI/dx-runtime
```
- dx_rt_npu_linux_driver, default is empty
```
https://github.com/DEEPX-AI/dx_rt_npu_linux_driver
```
- dx_stream, default is empty in dx-all-suite project
```
https://github.com/DEEPX-AI/dx_stream
```
- dx_app, default is empty in dx-all-suite project
```
https://github.com/DEEPX-AI/dx_app
```
- dx_fw, default is empty in dx-all-suite project
```
https://github.com/DEEPX-AI/dx_fw
```
- dx_rt, default is empty in dx-all-suite project
```
https://github.com/DEEPX-AI/dx_rt
```

### Tree
```
/dx-all-suite$ tree -d -L 1
.
├── docker
├── docs
├── dx-compiler
├── dx-modelzoo
├── dx-runtime
├── getting-started
├── scripts
├── tests
└── workspace

/dx-all-suite/dx-runtime$ tree -d -L 1
.
├── docs
├── dx_app
├── dx_fw
├── dx_rt
├── dx_rt_npu_linux_driver
├── dx_stream
├── scripts
└── venv-dx-runtime
```

### DXRT & RT driver version
```
$ dxrt-cli -s
DXRT v3.2.0
=======================================================
 * Device 0: M1, Accelerator type
---------------------   Version   ---------------------
 * RT Driver version   : v2.1.0
 * PCIe Driver version : v2.0.1
-------------------------------------------------------
 * FW version          : v2.5.0
--------------------- Device Info ---------------------
 * Memory : LPDDR5 5600 Mbps, 3.92GiB
 * Board  : M.2, Rev 1.0
 * Chip Offset : 0
 * PCIe   : Gen3 X4 [01:00:00]

NPU 0: voltage 750 mV, clock 1000 MHz, temperature 52'C
NPU 1: voltage 750 mV, clock 1000 MHz, temperature 51'C
NPU 2: voltage 750 mV, clock 1000 MHz, temperature 51'C
=======================================================
```

---
### Install `dx_engine`
```
./dx_rt/python_package/make_whl.sh
pip install dx_engine-1.1.4-cp310-cp310-linux_x86_64.whl
```
---
### Download Assets
```
cd dx_app/
./setup.sh
```

### Launch demo app
```
python3 src/python_example/object_detection/yolov9/yolov9_test.py   --model assets/models/YOLOV9S.dxnn     --video assets/videos/dron-citry-road.mov

python3 src/python_example/object_detection/yolov9/yolov9_sync.py   --model assets/models/YOLOV9S.dxnn     --video assets/videos/dron-citry-road.mov
```
### CLIP demo
- git clone project
```
https://github.com/DEEPX-AI/dx_clip_demo.git
```
- setup env
```
./setup.sh --app_type=opencv ~/Downloads/dx_clip_demo
./scripts/setup_clip_demo_app.sh --app_type=opencv --dxrt_src_path=../dx-all-suite/dx-runtime/dx_rt/
```
- source venv
```
source ./venv-opencv/bin/activate
```
- Error: ModuleNotFoundError: No module named 'dx_engine'
```
pip install ../dx-all-suite/dx-runtime/dx_rt/python_package/dx_engine-1.1.4-cp310-cp310-linux_x86_64.whl 
```
- setup demo asset
```
setup_clip_assets.sh
setup_clip_videos.sh
```
- demo
```
python clip_demo_app_opencv/dx_realtime_multi_demo.py
```


