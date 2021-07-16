/*
 * MainMenu        8
 * Ch1:Swamp     130
 * Ch2:Dash      174 => 176
 * Ch3:Surf      142 => 146
 * Ch4:Teleport  312 / 318
 * Ch5:Float     548 / 562 / 608 => 554 / 568 / 614
 * EndCutscene     2
 * Credits        58
 * TimeTrial      20
 */
state ("Omno-Win64-Shipping", "Beta") {
  uint level   : "Omno-Win64-Shipping.exe", 0x043DA828, 0x8, 0xD80, 0x2F0, 0xC5C; // 0x046BFC7C
  byte paused : "Omno-Win64-Shipping.exe", 0x044196C0, 0x28, 0x210, 0xB8, 0x8A8;
}

startup {
  settings.Add("split_chapters", true, "Split chapters");
  settings.SetToolTip("split_chapters", "Otherwise it will only split once before the final cutscene.");
}

init {
  vars.GetChapter = (Func<uint,int>) ((level) => {
    switch (level) {
      // Chapter 1: The Light (Jump)
      case 130:
        return 1;

      // Chapter 2: The Teaching (Dash)
      case 174:
      case 176:
        return 2;

      // Chapter 3: The Rift (Surf)
      case 142:
      case 146:
        return 3;

      // Chapter 4: The Gate (Teleport)
      case 312: case 318:
        return 4;

      // Chapter 5: The Pilgrimage (Float)
      case 548: case 562: case 608:
      case 554: case 568: case 614:
        return 5;

      // End & Credits
      case  2:
      case 58:
        return 6;
    }
    return -1;
  });

  vars.paused  = true;
  vars.level   = -1;
  vars.chapter = vars.GetChapter(current.level);

  print("[RCL] lvl " + current.level);
  print("[RCL] ch " + vars.chapter);
}


update {
  // Detect paused game
  var paused = current.paused == 1;
  if (vars.paused != paused) {
    vars.paused = paused;
    if (paused) { print("[RCL] pause"); }
    else { print("[RCL] run"); }
  }

  // Detect level change
  if (old.level != current.level) {
    print("[RCL] lvl " + current.level);
  }
  // make sure that the main menu is always detected
  else if (vars.level != 8 && current.level == 8) {
    print("[RCL] menu");
    vars.level = 8;
  }
}


// pause the clock
isLoading {
  return (
    (current.level == 8) // main menu
    ||
    vars.paused
  );
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
    vars.level   = current.level;
    vars.chapter = 1;
    print("[RCL] ch 1");
    return true;
  }
  return false;
}

// Progress the Chapter
split {
  var chapter = vars.GetChapter(current.level);
  if (vars.chapter < chapter) {
    vars.level = current.level;
    vars.chapter++;
    print("[RCL] ch " + vars.chapter);
    return (vars.chapter == 6 || settings["split_chapters"]);
  }
  return false;
}
