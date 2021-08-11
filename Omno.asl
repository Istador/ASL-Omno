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
state ("Omno-Win64-Shipping", "Release") {
  uint level  : "Omno-Win64-Shipping.exe", 0x04549A40, 0x20, 0x78, 0x308, 0x46C; // 0x046BFC7C
  byte paused : "Omno-Win64-Shipping.exe", 0x044196C0, 0x28, 0x210, 0xB8, 0x8A8;
}


startup {
  settings.Add("split_chapters", true, "Split between chapters");
  settings.SetToolTip("split_chapters", "Otherwise it will only split once at the end.");

  settings.CurrentDefaultParent = "split_chapters";
  settings.Add("split_chapter1", true, "Chapter 1 - The Light");
  settings.Add("split_chapter2", true, "Chapter 2 - The Teaching");
  settings.Add("split_chapter3", true, "Chapter 3 - The Rift");
  settings.Add("split_chapter4", true, "Chapter 4 - The Gate");
  settings.Add("split_chapter5", true, "Chapter 5 - The Pilgrimage");
  settings.SetToolTip("split_chapter1", "Split between chapter 1 and 2.");
  settings.SetToolTip("split_chapter2", "Split between chapter 2 and 3.");
  settings.SetToolTip("split_chapter3", "Split between chapter 3 and 4.");
  settings.SetToolTip("split_chapter4", "Split between chapter 4 and 5.");
  settings.SetToolTip("split_chapter5", "Split at the end of chapter 5. If \"Split before Credits\" is disabled it splits regardless.");
  settings.CurrentDefaultParent = null;

  settings.Add("split_credits", false, "Split before Credits");
  settings.SetToolTip("split_credits", "Use this, if you want to include the final cutscene into the time.");
}


init {
  vars.GetChapter = (Func<uint, int>) ((level) => {
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

      // Final Cutscene
      case  2:
        return 6;

      // Credits
      case 58:
        return (settings["split_credits"] ? 7 : 6);
    }
    return -1;
  });

  vars.paused       = true;
  vars.level        = -1;
  vars.stable       = false;
  vars.chapter      = vars.GetChapter(current.level);
  vars.last_chapter = (settings["split_credits"] ? 7 : 6);

  print("[RCL] lvl " + current.level);
  print("[RCL] ch "  + vars.chapter);
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
  vars.stable = old.level == current.level;
  if (! vars.stable) {
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
  if ( settings.ResetEnabled
    && vars.stable
    && vars.level    == 8
    && current.level == 130
  ) {
    print("[RCL] <reset>");
    return true;
  }
  return false;
}


// Start the run
start {
  if ( vars.stable
    && vars.level    == 8
    && current.level == 130
  ) {
    if (settings.StartEnabled) {
      print("[RCL] <start>");
    }
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
  if (vars.stable && vars.chapter < chapter) {
    vars.level = current.level;
    vars.chapter++;
    print("[RCL] ch " + vars.chapter);
    return (vars.chapter == vars.last_chapter || (settings["split_chapters"] && (
         (vars.chapter == 2 && settings["split_chapter1"])
      || (vars.chapter == 3 && settings["split_chapter2"])
      || (vars.chapter == 4 && settings["split_chapter3"])
      || (vars.chapter == 5 && settings["split_chapter4"])
      || (vars.chapter == 6 && settings["split_chapter5"])
    )));
  }
  return false;
}
