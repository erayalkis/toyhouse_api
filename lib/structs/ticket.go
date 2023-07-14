package structs

type Ticket struct {
	Tickets int `json:"ticket_count" binding:"required"`
	Profile Profile `json:"profile" binding:"required"`
}