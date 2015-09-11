package hooks

import (
	"encoding/json"
	"log"
	"net/http"
)

// HandleConfigHooks listen on 127.0.0.1 for config changes
func HandleConfigHooks(changes chan string) {
	http.HandleFunc("/api/v1/hook/southbound-update", func(w http.ResponseWriter, r *http.Request) {
		var data map[string]interface{}
		json.NewDecoder(r.Body).Decode(&data)
		log.Printf("%v\n", data)
		if sbd, ok := data["BP_HOOK_SOUTHBOUND_DATA"]; ok {
			for _, item := range sbd.([]interface{}) {
				if name, ok := item.(map[string]interface{})["interface"]; ok && name == "string" {
					if url, ok := item.(map[string]interface{})["url"]; ok {
						changes <- url.(string)
						return
					}
				}
			}
		}
		log.Printf("NO URL IN DATA CHANGE REQUEST")

	})
	log.Fatal(http.ListenAndServe("127.0.0.1:6789", nil))
}
