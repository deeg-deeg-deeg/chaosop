/*
2022, deeg / @deeg_deeg_deeg
*/

Engine_ChaosOp : CroneEngine {

	var <synths;


	*new { arg context, doneCallback;

		^super.new(context, doneCallback);
	}

	alloc {

		synths = {

			arg out = 0,
	    	freq01=20, freq02=20, freq03=20, mul01=1, mul02=0, mul03=0;

    	
	    var osc01, osc02, osc03, combo, signal;
	    
	 
		
		  osc01 = SinOsc.ar(freq01, 0, mul01, 0);
			osc02 = LFTri.ar(freq01, 0, mul02, 0);
			osc03 = LFSaw.ar(freq01, 1, mul03, 0);


      combo = osc01 + osc02 + osc03;


      signal = Pan2.ar(combo,0);

		    Out.ar(out, signal);

			}.play(args: [\out, context.out_b], target: context.xg);


	  	this.addCommand("mul01", "f", { arg msg;
			synths.set(\mul01, msg[1]);
		});

	  	this.addCommand("mul02", "f", { arg msg;
			synths.set(\mul02, msg[1]);
		});

	  	this.addCommand("mul03", "f", { arg msg;
			synths.set(\mul03, msg[1]);
		});
		
	  	this.addCommand("freq01", "f", { arg msg;
			synths.set(\freq01, msg[1]);
		});

	  	this.addCommand("freq02", "f", { arg msg;
			synths.set(\freq02, msg[1]);
		});

		this.addCommand("freq03", "f", { arg msg;
			synths.set(\freq03, msg[1]);
		});			





}
	
	
	free {
		synths.free;
	}
}

