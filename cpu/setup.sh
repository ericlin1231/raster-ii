if [ ! -d "litex" ]; then
    # Install LiteX
    if [ ! -f "litex_setup.py" ]; then
        wget https://raw.githubusercontent.com/enjoy-digital/litex/master/litex_setup.py
        chmod +x litex_setup.py
    fi
    ./litex_setup.py --init --install --config=standard
    cp CPU.mk litex/Makefile

    # Delete Redundant Packages
    ls | grep "pythondata-misc-.*" | xargs -d "\n" rm -rf
    ls | grep "pythondata-cpu-.*" | grep -v "vexriscv" | xargs -d "\n" rm -rf
    rm -rf liteeth litei2c litejesd204b litepcie litesata valentyusb
fi
