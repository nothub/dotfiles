//usr/bin/env -S go run "$0" "$@" ; exit
package main

import (
	"log"
	"os"
	"os/exec"
	"strconv"
	"strings"
)

var launchers = map[string]string{
	"/commands/custom/<Super>f":      "exo-open --launch FileManager",
	"/commands/custom/<Super>m":      "exo-open --launch MailReader",
	"/commands/custom/<Super>w":      "exo-open --launch WebBrowser",
	"/commands/custom/<Super>t":      "exo-open --launch TerminalEmulator",
	"/commands/custom/<Super>Return": "exo-open --launch TerminalEmulator",
}

var arrowTiling = map[string]string{
	"/xfwm4/custom/<Super>Left":  "tile_left_key",
	"/xfwm4/custom/<Super>Right": "tile_right_key",
	"/xfwm4/custom/<Super>Up":    "maximize_window_key",
}

var numpadTiling = map[string]string{
	"/xfwm4/custom/<Super>KP_1": "tile_down_left_key",
	"/xfwm4/custom/<Super>KP_2": "tile_down_key",
	"/xfwm4/custom/<Super>KP_3": "tile_down_right_key",
	"/xfwm4/custom/<Super>KP_4": "tile_left_key",
	"/xfwm4/custom/<Super>KP_5": "maximize_window_key",
	"/xfwm4/custom/<Super>KP_6": "tile_right_key",
	"/xfwm4/custom/<Super>KP_7": "tile_up_left_key",
	"/xfwm4/custom/<Super>KP_8": "tile_up_key",
	"/xfwm4/custom/<Super>KP_9": "tile_up_right_key",
}

func main() {
	setAll(launchers)

	set("/commands/custom/<Super>l", "xflock4")
	set("/commands/custom/<Super>p", "xfce4-display-settings --minimal")

	if isDesktop() {
		setAll(numpadTiling)
		setAll(arrowTiling)
	} else {
		setAll(arrowTiling)
	}
}

func set(prop string, val string) {
	reset(prop)
	runCmd("xfconf-query", []string{
		"--channel", "xfce4-keyboard-shortcuts",
		"--property", prop,
		"--create",
		"--type", "string",
		"--set", val,
	})
}

func setAll(props map[string]string) {
	for prop, val := range props {
		set(prop, val)
	}
}

func reset(prop string) {
	runCmd("xfconf-query", []string{
		"--channel", "xfce4-keyboard-shortcuts",
		"--property", prop,
		"--reset",
	})
}

func runCmd(c string, foo []string) {
	cmd := exec.Command(c, foo...)
	output, err := cmd.CombinedOutput()
	if len(strings.TrimSpace(string(output))) > 0 {
		log.Println(string(output))
	}
	if err != nil {
		log.Fatalln(err.Error())
	}
}

func isDesktop() bool {
	byts, err := os.ReadFile("/sys/class/dmi/id/chassis_type")
	if err != nil {
		log.Fatalln(err.Error())
	}
	val, err := strconv.ParseUint(strings.TrimSpace(string(byts)), 10, 0)
	if err != nil {
		log.Fatalln(err.Error())
	}
	switch val {
	case 3, 4, 5, 6, 7:
		return true
	default:
		return false
	}
}
