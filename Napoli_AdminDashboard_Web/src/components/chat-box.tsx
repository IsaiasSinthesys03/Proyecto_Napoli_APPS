import { formatDistanceToNow } from "date-fns";
import { es } from "date-fns/locale";
import { useState } from "react";

import { cn } from "@/lib/utils";

import { Button } from "./ui/button";
import { Card, CardContent, CardHeader, CardTitle } from "./ui/card";
import { Textarea } from "./ui/textarea";

interface ChatMessage {
  sender: "customer" | "driver" | "admin";
  text: string;
  timestamp: string;
}

interface ChatBoxProps {
  messages: ChatMessage[];
  onSendMessage: (message: string) => void;
}

export function ChatBox({ messages, onSendMessage }: ChatBoxProps) {
  const [newMessage, setNewMessage] = useState("");

  function handleSendMessage() {
    if (newMessage.trim() === "") return;
    onSendMessage(newMessage);
    setNewMessage("");
  }

  return (
    <Card>
      <CardHeader>
        <CardTitle>Chat del Pedido</CardTitle>
      </CardHeader>
      <CardContent>
        <div className="space-y-4">
          <div className="flex h-64 flex-col-reverse overflow-y-auto rounded-md border bg-muted/50 p-4">
            <div className="flex flex-col gap-4">
              {messages.map((msg, index) => (
                <div
                  key={index}
                  className={cn(
                    "flex max-w-[80%] flex-col gap-1",
                    msg.sender === "customer" ? "self-start" : "self-end",
                  )}
                >
                  <div
                    className={cn(
                      "rounded-lg p-3 text-sm",
                      msg.sender === "customer"
                        ? "bg-gray-200 text-gray-900"
                        : "bg-blue-500 text-white",
                    )}
                  >
                    <p className="font-bold">
                      {
                        {
                          customer: "Cliente",
                          driver: "Repartidor",
                          admin: "Tú (Admin)",
                        }[msg.sender]
                      }
                    </p>
                    <p>{msg.text}</p>
                  </div>
                  <span className="text-xs text-muted-foreground">
                    {formatDistanceToNow(new Date(msg.timestamp), {
                      addSuffix: true,
                      locale: es,
                    })}
                  </span>
                </div>
              ))}
            </div>
          </div>
          <div className="flex items-center gap-2">
            <Textarea
              placeholder="Escribe tu mensaje..."
              value={newMessage}
              onChange={(e) => setNewMessage(e.target.value)}
              rows={2}
            />
            <Button onClick={handleSendMessage}>Enviar</Button>
          </div>
        </div>
      </CardContent>
    </Card>
  );
}
