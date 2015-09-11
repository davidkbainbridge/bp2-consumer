package consumer

import (
	"bytes"
	"encoding/json"
	"io/ioutil"
	"log"
	"net/http"
	"strings"
)

// Consume - GET some text from one URL and POST it to another
func Consume(url string) {

	// Get some random text
	text, err := http.Get("http://loripsum.net/api/1/short/plaintext")
	if err != nil {
		log.Printf("ERROR: Failed to fetch text : %s\n", err)
		return
	}
	defer text.Body.Close()
	contents, err := ioutil.ReadAll(text.Body)
	if err != nil {
		log.Printf("ERROR: retrieving text from web service: %s", err)
		return
	}

	data := make(map[string]interface{})
	data["s"] = strings.Trim(string(contents), "\n")
	b, err := json.Marshal(data)
	if err != nil {
		log.Printf("ERROR: Unable to marshal data into JSON structure: %s\n", err)
		return
	}
	resp, err := http.Post(url + "uppercase", "application/json", bytes.NewReader(b))
	if err != nil {
		log.Printf("ERROR: Failed to POST to string service: %s\n", err)
		return
	}
	defer resp.Body.Close()
	if (int)(resp.StatusCode/100) != 2 {
		log.Printf("ERROR: Unexpected return code from string service: %s\n", resp.Status)
		return
	}
	var result map[string]interface{}
	if err := json.NewDecoder(resp.Body).Decode(&result); err != nil {
		log.Printf("ERROR: Unable to decode response from string service: %s\n", err)
		return
	}
	if err, ok := result["Err"]; ok {
		log.Printf("ERROR: Received exception from string service: %s\n", err)
		return
	}
	val, ok := result["v"]
	if !ok {
		log.Printf("ERROR: Did not receive value from string service")
		return
	}
	log.Printf("Converted string to '%s'\n", val)
}
