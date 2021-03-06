import CSI 1.0
import QtQuick 2.0
import QtGraphicalEffects 1.0
import './../Definitions' as Definitions
import './../Widgets' as Widgets

// #################################
// Thanks for looking into DJ SEMs S5 Screen modding
//
// Most of the functions used here are taken from
// - NI-Forum user "Sydes"   and
// - NI-Forum user "ErikMinekus"
//
// I looked at both of their great work, and simply create my own version out of that.
// So I took some parts of the original S5 Screens (DeckFooter and DeckHeader Files) and then copy/pasted
// from Sydes and ErikMinekus, plus a bit of rearranging.

// For more info please check:
// - http://djtechtools.com/2016/09/23/hack-kontrol-s8s5-screens-advanced-layouts/
// - https://www.native-instruments.com/forum/threads/s8-s5-display-mods.288222/
// #################################

//--------------------------------------------------------------------------------------------------------------------
//  DECK FOOTER
//--------------------------------------------------------------------------------------------------------------------

Item {
  id: deck_footer

  // QML-only deck types
  readonly property int thruDeckType:  4

  // This string property can be changed below. It shows up in the lower left corner of a Deck
  // It has no function at all, the string is simply displayed e.g. for "Branding" of your S5/S8 :)
  readonly property string custom_branding_name: ""

  // Here all the properties defining the content of the DeckFooter are listed. They are set in DeckView.
  property int    deck_Id:           0
  property string footerState:      "large" // this property is used to set the state of the footer (large/small)

  // color for empty cover bg
  readonly property variant coverBgEmptyColors: [colors.colorDeckBlueDark,    colors.colorDeckBlueDark,     colors.colorGrey48,   colors.colorGrey48  ]
  // color for empty cover circles
  readonly property variant circleEmptyColors:  [colors.rgba(0, 37, 54, 255),  colors.rgba(0,  37, 54, 255),                       colors.colorGrey24,   colors.colorGrey24  ]

  readonly property variant loopText:           ["/32", "/16", "1/8", "1/4", "1/2", "1", "2", "4", "8", "16", "32"]
  readonly property variant emptyDeckCoverColor:["Blue", "Blue", "White", "White"] // deckId = 0,1,2,3

  // these variables can not be changed from outside
  readonly property int speed: 40  // Transition speed

  readonly property int    deckType:    propDeckType.value
  readonly property bool   isLoaded:    (primaryKey.value > 0) || (deckType == DeckType.Remix)
  readonly property int    isInSync:    propIsInSync.value
  readonly property int    isMaster:    (propSyncMasterDeck.value == deck_Id) ? 1 : 0
  readonly property int    loopSizePos: footerPropertyLoopSize.value

  height: 45
  opacity: (primaryKey.value > 0 && footerState == "large") ? 1 : 0
  clip: false //true
  Behavior on opacity { NumberAnimation { duration: speed } }


  //--------------------------------------------------------------------------------------------------------------------
  // Helper function
  function toInt(val) { return parseInt(val); }

  //--------------------------------------------------------------------------------------------------------------------
  //  DECK PROPERTIES
  //--------------------------------------------------------------------------------------------------------------------

  AppProperty { id: propDeckType;               path: "app.traktor.decks." + (deck_Id+1) + ".type" }
  AppProperty { id: primaryKey;                 path: "app.traktor.decks." + (deck_Id+1) + ".track.content.primary_key" }
  AppProperty { id: propIsInSync;               path: "app.traktor.decks." + (deck_Id+1) + ".sync.enabled"; }
  AppProperty { id: propSyncMasterDeck;         path: "app.traktor.masterclock.source_id" }
  AppProperty { id: propSnap;                   path: "app.traktor.snap" }
  AppProperty { id: directThru;                 path: "app.traktor.decks." + (deck_Id+1) + ".direct_thru"; onValueChanged: { updateFooter() } }
  AppProperty { id: footerPropertyCover;        path: "app.traktor.decks." + (deck_Id+1) + ".content.cover_md5" }
  AppProperty { id: footerPropertyLoopActive;   path: "app.traktor.decks." + (deck_Id+1) + ".loop.active"; }
  AppProperty { id: footerPropertyLoopSize;     path: "app.traktor.decks." + (deck_Id+1) + ".loop.size"; }
  AppProperty { id: propTrackLength;            path: "app.traktor.decks." + (deck_Id+1) + ".track.content.track_length"; }
  AppProperty { id: propElapsedTime;            path: "app.traktor.decks." + (deck_Id+1) + ".track.player.elapsed_time"; }
  AppProperty { id: propMixerBpm;               path: "app.traktor.decks." + (deck_Id+1) + ".tempo.base_bpm" }
  AppProperty { id: propTempo;                  path: "app.traktor.decks." + (deck_Id+1) + ".tempo.tempo_for_display" }
  AppProperty { id: propKeyEnabled;             path: "app.traktor.decks." + (deck_Id+1) + ".track.key.lock_enabled" }

  //--------------------------------------------------------------------------------------------------------------------
  //  UPDATE VIEW
  //--------------------------------------------------------------------------------------------------------------------

  Component.onCompleted:  { updateFooter(); }
  onFooterStateChanged:   { updateFooter(); }
  onIsLoadedChanged:      { updateFooter(); }
  onDeckTypeChanged:      { updateFooter(); }
  onIsMasterChanged:      { updateFooter(); }

  function updateFooter() {
    updateCoverArt();
  }



  //--------------------------------------------------------------------------------------------------------------------
  //  DECK FOOTER TEXT
  //--------------------------------------------------------------------------------------------------------------------

// Custom Branding :)
  Rectangle {
    id: djSem_rectangle
    width: 60
    height: 36
    anchors.bottom: parent.bottom
    anchors.left: parent.left
    anchors.leftMargin: 10
    color: "transparent"

    // Label
    Text {
      anchors.top: parent.top
      anchors.left: parent.left
      color: "white"
      font.pixelSize: fonts.scale(12)
      font.family: "Pragmatica MediumTT"
      text: custom_branding_name
    }
  }

  // BPM
  Rectangle {
    id: bpm_rectangle
    width: 60
    height: 36
    anchors.bottom: parent.bottom
    anchors.left: djSem_rectangle.right
    anchors.leftMargin: 10
    color: "transparent"

    // Label
    Text {
      anchors.top: parent.top
      anchors.left: parent.left
      color: "white"
      font.pixelSize: fonts.scale(9)
      font.family: "Pragmatica MediumTT"
      text: "BPM"
    }

    // Master BPM
    Text {
      anchors.top: parent.top
      anchors.right: parent.right
      color: "orange"
      font.pixelSize: fonts.scale(9)
      font.family: "Pragmatica MediumTT"
      text: "MASTER"
      visible: isMaster
    }

    // Decimal Value
    Text {
      id: bpm_anchor
      anchors.bottom: parent.bottom
      anchors.bottomMargin: 6
      anchors.right: parent.right
      color: isMaster ? "orange" : "white"
      font.pixelSize: fonts.middleFontSize
      font.family: "Pragmatica"

      function getBpmDecimalString() {
        var bpm = propMixerBpm.value * propTempo.value;
        var dec = Math.round((bpm % 1) * 100);
        if (dec == 100) dec = 0;

        var decStr = dec.toString();
        if (dec < 10) decStr = "0" + decStr;

        return "." + decStr;
      }
      text: getBpmDecimalString()
    }

    // Whole Number Value
    Text {
      anchors.bottom: parent.bottom
      anchors.bottomMargin: 5
      anchors.right: bpm_anchor.left
      color: isMaster ? "orange" : "white"
      font.pixelSize: fonts.largeValueFontSize
      font.family: "Pragmatica"

      function getBpmString() {
        return Math.floor((propMixerBpm.value * propTempo.value).toFixed(2)).toString();
      }
      text: getBpmString()
    }

    // Synced BPM
    Rectangle {
      anchors.top: parent.top
      anchors.topMargin: 1
      anchors.right: parent.right
      width: 27
      height: 9
      color: colors.colorGreen
      border.color: colors.colorGreen
      radius: 2
      visible: isInSync && !isMaster

      Text {
        anchors.centerIn: parent
        color: "black"
        font.pixelSize: fonts.scale(9)
        font.family: "Pragmatica MediumTT"
        text: "SYNC"
      }
    }
  } // End BPM Rectangle

  // REMAINING TIME
  Rectangle {
    id: remainingTime_rectangle
    width: 90
    height: 36
    anchors.bottom: parent.bottom
    anchors.left: bpm_rectangle.right
    anchors.leftMargin: 50
    color: "transparent"

    // Label
    Text {
      anchors.top: parent.top
      anchors.left: parent.left
      anchors.leftMargin: 1
      color: "white"
      font.pixelSize: fonts.scale(9)
      font.family: "Pragmatica MediumTT"
      text: "REMAIN"
    }
    // Milliseconds Value
    Text {
      id: time_anchor
      anchors.bottom: parent.bottom
      anchors.bottomMargin: 6
      anchors.right: parent.right
      color: "white"
      font.pixelSize: fonts.middleFontSize
      font.family: "Pragmatica"

      function getRemainingTimeDecimalString() {
        var seconds = propTrackLength.value - propElapsedTime.value;
        if (seconds < 0) seconds = 0;

        var ms = Math.floor((seconds % 1) * 1000);

        var msStr = ms.toString();
        if (ms < 10) msStr = "0" + msStr;
        if (ms < 100) msStr = "0" + msStr;

        return "." + msStr;
      }
      text: getRemainingTimeDecimalString()
    }
    // Minutes and Seconds Value
    Text {
      anchors.bottom: parent.bottom
      anchors.bottomMargin: 5
      anchors.right: time_anchor.left
      color: "white"
      font.pixelSize: fonts.largeValueFontSize
      font.family: "Pragmatica"

      function getRemainingTimeString() {
        var seconds = propTrackLength.value - propElapsedTime.value;
        if (seconds < 0) seconds = 0;

        var sec = Math.floor(seconds % 60);
        var min = (Math.floor(seconds) - sec) / 60;

        var secStr = sec.toString();
        if (sec < 10) secStr = "0" + secStr;

        var minStr = min.toString();
        if (min < 10) minStr = "0" + minStr;

        return minStr + ":" + secStr;
      }
      text: getRemainingTimeString()
    }

    // Quantize
    Text {
      anchors.top: parent.top
      anchors.right: parent.right
      anchors.rightMargin: 1
      color: "red"
      font.pixelSize: fonts.scale(9)
      font.family: "Pragmatica MediumTT"
      text: "QUANTIZE"
      visible: propSnap.value
    }
  }

  // TEMPO
  Rectangle {
    id: tempo_rectangle
    width: 70
    height: 36
    anchors.bottom: parent.bottom
    anchors.left: remainingTime_rectangle.right
    anchors.leftMargin: 30
    color: "transparent"

    // Label
    Text {
      anchors.top: parent.top
      anchors.left: parent.left
      color: "white"
      font.pixelSize: fonts.scale(9)
      font.family: "Pragmatica MediumTT"
      text: "TEMPO"
    }
    // Percent Sign
    Text {
      id: tempo_anchor
      anchors.bottom: parent.bottom
      anchors.bottomMargin: 6
      anchors.right: parent.right
      color: "white"
      font.pixelSize: fonts.smallFontSize
      font.family: "Pragmatica"
      text: "%"
    }
    // Value
    Text {
      anchors.bottom: parent.bottom
      anchors.bottomMargin: 5
      anchors.right: tempo_anchor.left
      color: "white"
      font.pixelSize: fonts.largeValueFontSize
      font.family: "Pragmatica"

      function getTempoString() {
        var tempo = propTempo.value - 1;
        return ((tempo <= 0) ? "" : "+") + (tempo * 100).toFixed(2).toString();
      }
      text: getTempoString()
    }

    // Key Lock
    Text {
      anchors.top: parent.top
      anchors.right: parent.right
      anchors.rightMargin: 1
      color: "red"
      font.pixelSize: fonts.scale(9)
      font.family: "Pragmatica MediumTT"
      text: "LOCK"
      visible: propKeyEnabled.value
    }
  }

  // LOOP SIZE
  Rectangle {
    width: 25
    height: 36
    anchors.bottom: parent.bottom
    anchors.right: parent.right
    anchors.rightMargin: 20
    color: "transparent"

    Text {
      anchors.top: parent.top
      anchors.left: parent.left
      color: "white"
      font.pixelSize: fonts.scale(9)
      font.family: "Pragmatica MediumTT"
      text: "LOOP"
    }
    Rectangle {
      anchors.bottom: parent.bottom
      anchors.bottomMargin: 6
      anchors.left: parent.left
      width: parent.width
      height: 15
      color: footerPropertyLoopActive.value ? colors.colorGreen : "transparent"
      border.color: footerPropertyLoopActive.value ? colors.colorGreen : "gray"
      border.width: 1
      radius: 2

      Text {
        anchors.fill: parent
        color: footerPropertyLoopActive.value ? "black" : "gray"
        font.pixelSize: fonts.scale(14)
        font.family: "Pragmatica MediumTT"
        horizontalAlignment: Text.AlignHCenter
        text: loopText[loopSizePos]
      }
    }
  }
}
