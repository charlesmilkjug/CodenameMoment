/* 
   Script by APurples
   If you wish to add this to your mod, you have full permission to do so as long as you credit me.
*/ 

import flixel.text.FlxTextBorderStyle;
import flixel.util.FlxColor;

var botplayTxt, playbackRateTxt:FlxText;

var startDrain:Bool == false;
var startPoison:Bool == false;

var poisonAmount:Float = 0.75;

function create(){
    botplayTxt = new FunkinText(400, 83, FlxG.width - 800, "Botplay", 40);
    botplayTxt.setFormat(Paths.font("vcr.ttf"), 40, FlxColor.WHITE, "center", FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
    botplayTxt.scrollFactor.set();
    botplayTxt.borderSize = 1.25;
    botplayTxt.alpha = 0;
    botplayTxt.cameras = [camHUD];
    if (FlxG.save.data.botplay) add(botplayTxt);

    playbackRateTxt = new FunkinText(400, botplayTxt.y - 25, FlxG.width - 800, "Playback Rate: " + FlxG.save.data.playbackRate, 40);
    playbackRateTxt.setFormat(Paths.font("vcr.ttf"), 23.5, FlxColor.WHITE, "center", FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
    playbackRateTxt.scrollFactor.set();
    playbackRateTxt.borderSize = 1.25;
    playbackRateTxt.alpha = 0;
    playbackRateTxt.cameras = [camHUD];
    if (FlxG.save.data.midsongPlaybackRate) add(playbackRateTxt);
}

function update(elapsed){
    playbackRateTxt.text = "Playback Rate: " + FlxG.save.data.playbackRate;

    if (FlxG.save.data.botplay) player.cpu = true;

    if (FlxG.save.data.noMiss && misses > 0) health = -0.1;

    if (FlxG.save.data.invisNotes) playerStrums.notes.forEachAlive(function(notes) notes.alpha = 0);

    if (FlxG.save.data.earthquake){
        camGame.shake(0.0025 * FlxG.save.data.earthquakeMult, inst.length, null, true);
        camHUD.shake(0.0025 * FlxG.save.data.earthquakeMult, inst.length, null, true);
    }

    if (FlxG.save.data.seasick){
        camGame.angle += Math.cos(Conductor.songPosition * Conductor.bpm / 100 / 500) * (0.035 * FlxG.save.data.seasickMult);
        camHUD.angle += Math.cos(Conductor.songPosition * Conductor.bpm / 100 / 500) * (0.035 * FlxG.save.data.seasickMult);
    }

    if (FlxG.save.data.midsongPlaybackRate){
        if (FlxG.save.data.playbackRate < 3){
            if(FlxG.keys.justPressed.E){
                FlxG.save.data.playbackRate += 0.25;
                inst.pitch = FlxG.save.data.playbackRate;
                vocals.pitch = FlxG.save.data.playbackRate;
                playbackRateTxt.alpha = 1;
                new FlxTimer().start(2.5, function(tmr:FlxTimer){
                    FlxTween.tween(playbackRateTxt, {alpha: 0}, 1);
                });
            }
        }

        if (FlxG.save.data.playbackRate > 0.25){
            if(FlxG.keys.justPressed.Q){
                FlxG.save.data.playbackRate -= 0.25;
                inst.pitch = FlxG.save.data.playbackRate;
                vocals.pitch = FlxG.save.data.playbackRate;
                playbackRateTxt.alpha = 1;
                new FlxTimer().start(2.5, function(tmr:FlxTimer){
                    FlxTween.tween(playbackRateTxt, {alpha: 0}, 1);
                });
            }
        }
    }
}

function postCreate(){
    inst.pitch = FlxG.save.data.playbackRate;
    vocals.pitch = FlxG.save.data.playbackRate;

    if (FlxG.save.data.practice) canDie = canDadDie = false;

    if (FlxG.save.data.enableSS) scrollSpeed = FlxG.save.data.customScrollSpeed;
}

function postUpdate(){
    if (startDrain){
        if (FlxG.save.data.healthDrain){
            if (!PlayState.opponentMode){
                if (health > 0.1) {health -= 0.000125 * FlxG.save.data.healthDrainMult;}
            }else{
                if (health > 0.1) {health += 0.000125 * FlxG.save.data.healthDrainMult;}
            }
        }
    }

    if (startPoison){
        poisonAmount + 0.25;
        if (!PlayState.opponentMode){
            {health -= 0.00025 * poisonAmount;}
        }else{
            {health += 0.00025 * poisonAmount;}
        }
    }
}

// thanks srt
function onPlayerHit(event) {
    if (FlxG.save.data.sicksOnly && event.accuracy != null && event.accuracy != 1) health = -0.1;
}

function onPlayerMiss(){
    if (FlxG.save.data.poison){
        startPoison = true;
        poisonAmount += 0.25;
        if (!PlayState.opponentMode){
            healthBar.createFilledBar(0xFFFF0000, 0xFF8B33FF);
            iconP1.color = 0xFF8B33FF;
            boyfriend.color = 0xFF8B33FF;
        }else{
            healthBar.createFilledBar(0xFF8B33FF, 0xFFFF0000);
            iconP2.color = 0xFF8B33FF;
            dad.color = 0xFF8B33FF;
        }
    }
}

function onSongStart(){
    startDrain = true;
    FlxTween.tween(botplayTxt, {y: 115}, 1, {ease: FlxEase.sineInOut, type: 4}); // type 4 means looping
    FlxTween.tween(botplayTxt, {alpha: 1}, 1);
}

function stepHit(){
    if (FlxG.save.data.trampoline){
        if (curStep % 4 == 0){
            FlxTween.tween(camHUD, {y: -15 * FlxG.save.data.trampolineMult}, Conductor.stepCrochet * 0.002, {ease: FlxEase.quadOut});
            trace("boing"); // feeling silly :3
        }
        if (curStep % 4 == 2){
            FlxTween.tween(camHUD, {y: 0}, Conductor.stepCrochet * 0.002, {ease: FlxEase.sineIn});
        }
    }
}