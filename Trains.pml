// =============================================
// CHANNELS (for communication between signals and boxes)
// =============================================

// Block section channels (trains pass here)
chan BlockSecAB = [1] of {int}; // Trains from A to B
chan BlockSecBC = [1] of {int}; // Trains from B to C

// Channels for communication between Signals and SignalBoxes
chan CircuitA = [0] of {byte};    // SignalA → SignalBoxA (e.g., request to enter)
chan SigChanA = [0] of {byte};    // SignalBoxA → SignalA (e.g., green light)

// You'll need similar channels for SignalB <→ SignalBoxB and SignalC <→ SignalBoxC
chan CircuitB = [0] of {byte};
chan SigChanB = [0] of {byte};

chan CircuitC = [0] of {byte};
chan SigChanC = [0] of {byte};

// Bell line messages (between signalboxes, e.g., "is line clear?", "train entering")
chan bellAB = [0] of {byte};
chan bellBA = [0] of {byte};

chan bellBC = [0] of {byte};
chan bellCB = [0] of {byte};

// Block instrument states: 0 = line_clear, 1 = line_ready, 2 = train_on_line
byte instrAB = 0;
byte instrBC = 0;

//////////////////////////////////////////////////////////
// PROCESS: SignalA – Train enters the first block
//////////////////////////////////////////////////////////
proctype SignalA() {
    do
    :: 
        CircuitA!1; // Ask SignalBoxA for permission to enter
        SigChanA?1; // Wait for green light

        // Now send the train into the first block
        BlockSecAB!1;
    od
}

//////////////////////////////////////////////////////////
// PROCESS: SignalB – Train moves from AB to BC
//////////////////////////////////////////////////////////
proctype SignalB() {
    int train;
    do
    ::
        CircuitB!1;     // Ask SignalBoxB to proceed
        SigChanB?1;     // Wait for green signal

        BlockSecAB?train;
        BlockSecBC!train;
    od
}

//////////////////////////////////////////////////////////
// PROCESS: SignalC – Train exits the final block
//////////////////////////////////////////////////////////
proctype SignalC() {
    int train;
    do
    ::
        CircuitC!1;    // Ask SignalBoxC for exit clearance
        SigChanC?1;    // Wait for green signal

        BlockSecBC?train;
    od
}

//////////////////////////////////////////////////////////
// PROCESS: SignalBoxA – Forwarding role only
//////////////////////////////////////////////////////////
proctype SignalBoxA() {
    byte msg;
    do
    ::
        CircuitA?msg;          // Wait for SignalA to request permission
        bellAB!1;              // Send "call attention" to B
        bellBA?msg;            // Wait for response

        bellAB!2;              // Send "is line clear?"
        bellBA?msg;            // Wait for response that it’s clear

        // Wait for "line_ready" from SignalBoxB
        if
        :: instrAB == 1 ->    // Only give green if line_ready
            SigChanA!1;
            bellAB!3;         // Notify "train entering section"
        fi
    od
}

//////////////////////////////////////////////////////////
// PROCESS: SignalBoxB – Full control logic
//////////////////////////////////////////////////////////
proctype SignalBoxB() {
    byte msg;
    do
    ::
        bellAB?msg;    // Receive "call attention" from A
        bellBA!msg;    // Acknowledge

        bellAB?msg;    // Receive "is line clear?"
        if
        :: instrAB == 0 ->    // If line_clear
            bellBA!msg;       // Acknowledge
            instrAB = 1;      // Set to line_ready
        fi

        bellAB?msg;    // Receive "train entering"
        instrAB = 2;   // Set to train_on_line

        // Wait until train passes into BC
        BlockSecAB?1;
        BlockSecBC!1;

        // Notify A that train has exited
        bellBA!4;      // "train out of section"
        instrAB = 0;   // Back to line_clear
    od
}

//////////////////////////////////////////////////////////
// PROCESS: SignalBoxC – Accepting role only
//////////////////////////////////////////////////////////
proctype SignalBoxC() {
    byte msg;
    do
    ::
        CircuitC?msg;
        if
        :: instrBC == 0 -> // If section BC is clear
            instrBC = 2;   // Mark as occupied
            SigChanC!1;    // Let train exit
            instrBC = 0;   // After train passed, clear line
        fi
    od
}

//////////////////////////////////////////////////////////
// MAIN INIT BLOCK
//////////////////////////////////////////////////////////
init {
    atomic {
        run SignalA();
        run SignalB();
        run SignalC();

        run SignalBoxA();
        run SignalBoxB();
        run SignalBoxC();
    }
}
