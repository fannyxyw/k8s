package main
import (
"fmt"
"log"
"net/http"
"os"
)
func GetEnvDefault(key, defVal string) string {
	val, ex := os.LookupEnv(key)
	if !ex {
		return defVal
	}
	return val
}

func handler(w http.ResponseWriter, r *http.Request) {
    log.Print("Hello world received a request.")
    version := GetEnvDefault("VERSION", "v1")
    log.Println(version)
    fmt.Fprintf(w, "Hello world %s\n",version)
}

func main() {
    log.Print("Hello world sample started.")
    http.HandleFunc("/hello", handler)
    port := GetEnvDefault("PORT", "80")
    log.Fatal(http.ListenAndServe(fmt.Sprintf(":%s", port), nil))
} 
