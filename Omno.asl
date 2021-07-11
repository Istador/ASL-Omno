/*
 * MainMenu        8
 * Ch1:Swamp     130
 * Ch2:Dash      174
 * Ch3:Surf      142
 * Ch4:Teleport  312 / 318
 * Ch5:Float     548 / 562 / 608
 * EndCutscene     2
 * Credits        58
 */
state ("Omno-Win64-Shipping", "Beta") {
  uint level : "Omno-Win64-Shipping.exe", 0x043DA828, 0x8, 0xD80, 0x2F0, 0xC5C; // 0x046BFC7C
}

init {
  vars.level = current.level;
  print("[RCL] level " + current.level);
}

update {
  if (old.level != current.level) {
    print("[RCL] level " + current.level);
    // make sure that the main menu is always detected
    if (vars.level != 8 && current.level == 8) {
      print("[RCL] main menu");
      vars.level = 8;
    }
  }
}

// pause the clock
isLoading {
  // TODO: reliably detect the in-game pause menu
  return (current.level == 8 || current.level == 0);
}

reset {
  // Going from the Main Menu to the first area resets the timer
  // Consequence: Continue during the first chapter will not work
  if (vars.level == 8 && current.level == 130) {
    print("[RCL] <reset>");
    return true;
  }
  return false;
}

// Start the run
start {
  if (vars.level == 8 && current.level == 130) {
    print("[RCL] <start>");
    vars.level = current.level;
    return true;
  }
  return false;
}

// Progress the Chapter
split {
  if ( // Ch1 => Ch2
    (vars.level == 130 && current.level == 174)
    || // Ch2 => Ch3
    (vars.level == 174 && current.level == 142)
    || // Ch3 => Ch4
    (vars.level == 142 && (current.level == 312 || current.level == 318))
    || // Ch4 => Ch5
    ((vars.level == 312 || vars.level == 318) && (current.level == 548 || current.level == 562 || current.level == 608))
    || // Ch5 => Final Cutscene
    ((vars.level == 548 || vars.level == 562 || vars.level == 608) && current.level == 2)
  ) {
    print("[RCL] <split> " + current.level);
    vars.level = current.level;
    return true;
  }
  return false;
}
