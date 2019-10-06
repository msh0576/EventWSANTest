/*
 * Copyright (c) 2005-2006 Rincon Research Corporation
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 * - Redistributions of source code must retain the above copyright
 *   notice, this list of conditions and the following disclaimer.
 * - Redistributions in binary form must reproduce the above copyright
 *   notice, this list of conditions and the following disclaimer in the
 *   documentation and/or other materials provided with the
 *   distribution.
 * - Neither the name of the Rincon Research Corporation nor the names of
 *   its contributors may be used to endorse or promote products derived
 *   from this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 * ``AS IS'' AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
 * FOR A PARTICULAR PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL THE
 * RINCON RESEARCH OR ITS CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
 * INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 * SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
 * HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
 * STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED
 * OF THE POSSIBILITY OF SUCH DAMAGE
 */
 
/**
 * Test the effectiveness of the PacketLink layer
 *
 * Transmitter != 0
 * Receiver == 0
 *
 * Expect:
 *   Transmitter (ID not 0) -
 *     led1 toggling on every successfully delivered message
 *     led0 toggling on every unsuccessfully delivered message (and stay on
 *       until the next dropped packet)
 *   
 *   Receiver (ID 0) -
 *     Leds represent the binary count of sets of messages that were dropped.
 *     Ideally, if the transmitter and receiver are in range of each other, 
 *     the receiver's LEDs should never turn on.  You can pull the receiver
 *     out of range for up to two seconds before the transmission will fail.
 *     If you aren't convinced the receiver is doing anything because its 
 *     leds aren't flashing, just turn it off and watch the transmitter's
 *     reaction.
 *
 * @author David Moss
 */
  
#include "TestPacketLink.h"

module TestPacketLinkP {
  uses {
    interface Boot;
    interface SplitControl;
    interface AMSend;
    interface AMPacket;
    interface Receive;
    interface PacketLink;
    interface Leds;
  }
}

implementation {

  /** The message we'll be sending */
  message_t myMsg;
  
  /** The local count we're sending or should receive on each unique message */
  uint32_t count;
  
  /** The total number of packets missed by the receiver */
  uint8_t missedPackets;
  
  /** True if this mote is the transmitter mote */
  bool transmitter;
  
  enum {
    MSG_DESTINATION = 0,
  };
  
  /***************** Prototypes ****************/
  task void send();
  
  /***************** Boot Events ****************/
  event void Boot.booted() {
    /*
     * Setup this message in advance to retry up to 50 times with 40 ms of
     * delay between each message.  50 * 40 ms = 2 seconds before it quits.
     * It only needs to be setup once to be stored in the msg's metadata.
     */
    call PacketLink.setRetries(&myMsg, 50);
    call PacketLink.setRetryDelay(&myMsg, 40);
    missedPackets = 0;
    count = 0;
    transmitter = (call AMPacket.address() != 0);
    call SplitControl.start();
  }
  
  /***************** SplitControl Events *****************/
  event void SplitControl.startDone(error_t error) {
    if(transmitter) {
      post send();
    }
  }
  
  event void SplitControl.stopDone(error_t error) {
  }

  /***************** AMSend Events ****************/
  event void AMSend.sendDone(message_t *msg, error_t error) {
    if(call PacketLink.wasDelivered(msg)) {
      call Leds.led1Toggle();
    } else {
      call Leds.led0Toggle();
    }
    
    count++;
    ((PacketLinkMsg *) call AMSend.getPayload(&myMsg))->count = count;
    post send();
  }
  
  /***************** Receive Events ****************/
  event message_t *Receive.receive(message_t *msg, void *payload, uint8_t len) {
    PacketLinkMsg *linkMsg = (PacketLinkMsg *) payload;
    
    if(transmitter) {
      return msg;
    }
    
    if(linkMsg->count != count) {
      if(count != 0) {
        missedPackets++;
        call Leds.set(missedPackets);
      }
    }
    
    count = linkMsg->count;
    count++;
    return msg;
  }
  
  /***************** Tasks ****************/
  task void send() {
    if(call AMSend.send(MSG_DESTINATION, &myMsg, sizeof(PacketLinkMsg)) != SUCCESS) {
      post send();
    }
  }
}

