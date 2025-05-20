#define train_in 1; // a bit

// example mtype declaration
mtype = { green, red, attention, attention_ack };

// channels
chan BlockSecAB = [2] of { bit }; 
chan BlockSecBC = [2] of { bit }; 
chan CircuitA = [1] of { bit }; 
chan SigChanA = [0] of { mtype }; 
chan BellAB = [0] of { mtype }; 
chan BellBA = [0] of { mtype };

// more are required...

proctype SignalA(chan out_track, toSigBox, fromSigBox) {
  mtype colour = red;

  do
  :: // inform SignalBox that train is approaching
  :: // get input colour from SignalBox -> if green -> allow out_track!train
  od
}

proctype SignalBoxA(chan toSignal, fromSignal, bell in/out channels, instrument in channel) {
  // local mtype variables for receiving bell and instrument communications
  
  do
  :: //(fromSignal?[1]) - detect approaching train -> turn off train detection -> initiate protocol interaction with SignalBoxB 
  :: // receive bell input ->
    if
    :: case of input 1 -> reaction 1
    ::
    ::
    ::
    :: case of input 4 -> reaction 4
    fi
  :: // receive bell input ->
  od
}
    
   protype SignalB(chan in_track, out_track, toSigBox, fromSigBox) {
  // analogous to SignalA
}

proctype SignalBoxB(chan toSignal, fromSignal, bell, in/out channels, instrument in/out channels) {
  // local mtype variables for receiving bell and instrument communications
    
  do
  :: //(fromSignal?[1]) - detect approaching train -> turn off train detection -> initiate protocol interaction with SignalBoxC 
  :: // receive bell input from SignalBoxA ->
    if
    :: case of input 1 -> reaction 1
    ::
    ::
    :: case of input 4 -> reaction 4
    fi
      // Note: turn train detection on after finishing protocol interaction with SignalBoxA
  :: // receive bell input from SignalBoxC ->
    if
    :: case of input 1 -> reaction 1
    ::
    ::
    ::
    :: case of (input == train_out) -> turn on train detection back on again -> reaction 5
    fi
  :: // receive instrument input
  od
}

proctype signalC(chan in_track, toSigBox) {
  do
  :: in_track?train -> tosigBox!train
  od
}

proctype SignalBoxC(chan fromSignal, bell_in, bell_out, instrument) {
  // local mtype variable for receiving bell communications
  
  do
  :: //(fromsignal? [1]) - detect approaching train -> turn off train detection -> send out attention bell output 
  :: // receive bell input ->
    if
    :: case of input 1 -> reaction 1
    ::
    ::
    :: case of input 4 -> reaction 4
    fi
  od
}

init {
  atomic {
    run each proctype
  }
}
