package main

import (
	"log"
	"time"

	"github.com/davidkbainbridge/bp2-consumer/consumer"
	"github.com/davidkbainbridge/bp2-consumer/hooks"
)

func main() {
	log.Println("Hello World")
	ticker := time.NewTicker(5 * time.Second)
	change := make(chan string)
	go hooks.HandleConfigHooks(change)
	quit := make(chan struct{})
	var url string = ""
	for {
		select {
		case <-ticker.C:
			go consumer.Consume(url)
			break
		case v := <-change:
			url = v
			log.Printf("GOT CHANGE '%s'\n", url)
			break
		case <-quit:
			ticker.Stop()
			return
		}
	}
}
