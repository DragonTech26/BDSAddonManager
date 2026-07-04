# Use this script for shared data
extends Node

var WorldPath: String = ""
var WorldResourcePackPath: String = ""
var WorldBehaviorPackPath: String = ""
var WorldName: String = ""
var RPList: Array = []
var BPList: Array = []
var WorldLoaded: bool = false
var HasUnsavedChanges: bool = false
var ServerPing: bool = false
var ServerPingData: String = ""
var ServerIP: String = ""
var ServerPort: int
