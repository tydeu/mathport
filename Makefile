all: mathport

mathport-lib:
	cd Lib && lake build-lib

mathport-app:
	cd Lib && lake build-bin

mathport: mathport-app

clean:
	rm -rf Lib/build/ App/build/

unport:
	rm -rf Lib4 Logs/*
	git checkout HEAD -- Lib4

port-lean: mathport
	LEAN_PATH=./Lib4:./Lib/build/lib time ./App/build/bin/MathportApp config.json Lean3::all >> Logs/mathport.out 2> Logs/mathport.err
	LEAN_PATH=./Lib4:./Lib/build/lib lean --o=./Lib4/Lean3.olean                      ./Lib4/Lean3.lean

port-mathlib: mathport
	LEAN_PATH=./Lib4:./Lib/build/lib time ./App/build/bin/MathportApp config.json Lean3::all Mathlib::all >> Logs/mathport.out 2> Logs/mathport.err
	LEAN_PATH=./Lib4:./Lib/build/lib lean --o=./Lib4/Lean3.olean                      ./Lib4/Lean3.lean
	LEAN_PATH=./Lib4:./Lib/build/lib lean --o=./Lib4/Mathlib.olean                    ./Lib4/Mathlib.lean

lean3-predata:
	mkdir -p PreData
	rm -rf PreData/Lean3
	find $(LEAN3_LIB) -name "*.olean" -delete # ast only exported when oleans not present
	LEAN_PATH=$(LEAN3_LIB)                 $(LEAN3_BIN)/lean --make --recursive --ast --tlean $(LEAN3_LIB)
	LEAN_PATH=$(LEAN3_LIB):$(LEAN3_PKG)    $(LEAN3_BIN)/lean --make --recursive --ast --tlean $(LEAN3_PKG)
	cp -r $(LEAN3_LIB) PreData/Lean3
	find PreData/ -name "*.lean" -delete
	find PreData/ -name "*.olean" -delete

mathlib-predata: lean3-predata
	rm -rf PreData/Mathlib
	find $(MATHLIB3_SRC) -name "*.olean" -delete # ast only exported when oleans not present
	LEAN_PATH=$(LEAN3_LIB):$(MATHLIB3_SRC)  $(LEAN3_BIN)/lean --make --recursive --ast   $(MATHLIB3_SRC)
	LEAN_PATH=$(LEAN3_LIB):$(MATHLIB3_SRC)  $(LEAN3_BIN)/lean --make --recursive --tlean $(MATHLIB3_SRC)
	cp -r $(MATHLIB3_SRC) PreData/Mathlib3
	find PreData/ -name "*.lean" -delete
	find PreData/ -name "*.olean" -delete
