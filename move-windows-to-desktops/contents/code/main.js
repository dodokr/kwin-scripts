// Code inpired by:
// https://gitlab.com/carmanaught/kwin-scripts/-/blob/master/move-windows-to-desktops/contents/code/main.js?ref_type=heads

// Check if we're using KWin 6. If not, assume it's KWin 5.
const isKWIN6 = typeof workspace.windowList === 'function';

// True modulo. Result is always positive.
function mod(n, m) {
    return ((n % m) + m) % m;
}

// Move the active window by a relative offset (delta = -1 for left, +1 for
// right), wrapping around at the edges with modulo, and follow it there.
function moveWindowDelta(delta) {
    var desktops = isKWIN6 ? workspace.desktops : null;
    var numDesktops = isKWIN6 ? desktops.length : workspace.desktops;
    if (numDesktops < 1) {
        return;
    }

    var thisWin = workspace[(isKWIN6 ? "activeWindow" : "activeClient")];
    if (!thisWin || thisWin.onAllDesktops) {
        return;
    }

    var cur = isKWIN6 ? workspace.currentDesktop.x11DesktopNumber : workspace.currentDesktop;
    // Desktop numbers are 1-based, transform to 0-base
    var dest = mod(cur - 1 + delta, numDesktops);

    if (isKWIN6) {
        var destDesktop = desktops[dest]; // this is 0-based. Bruh
        if (!destDesktop) {
            return;
        }
        thisWin.desktops = [destDesktop];
        workspace.currentDesktop = destDesktop;
        // Activating the window also raises it, so it isn't left behind the
        // other windows on the destination desktop.
        workspace.activeWindow = thisWin;
    } else {
        // KWin 5: step one desktop at a time with the previous/next slots.
        // The approach the original script's author used and had working.
        var steps = Math.abs(cur - dest)
        var slot = cur > dest ? "slotWindowToPreviousDesktop" : "slotWindowToNextDesktop";
        for (var i = 0; i < steps; ++i) {
            workspace[slot]();
        }
        if (steps === 0) {
            workspace.activeClient = thisWin;
        }
        // TODO: Direct assignment is simpler and maybe works, but
        // I haven't tested it since I have Plasma 6:
        // thisWin.desktop = dest + 1;
        // workspace.currentDesktop = dest + 1;
    }
}

if (registerShortcut) {
    registerShortcut("Move with Window to Previous Desktop",
        "Move with Window to Previous Desktop",
        "",
        function() { moveWindowDelta(-1); }
    );
    registerShortcut("Move with Window to Next Desktop",
        "Move with Window to Next Desktop",
        "",
        function() { moveWindowDelta(1); }
    );
}
