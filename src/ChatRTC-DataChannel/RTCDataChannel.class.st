Class {
	#name : 'RTCDataChannel',
	#superclass : 'Object',
	#instVars : [
		'channel',
		'messageBlock'
	],
	#category : 'ChatRTC-DataChannel',
	#package : 'ChatRTC-DataChannel'
}

{ #category : 'initialization' }
RTCDataChannel >> initialize [

	super initialize.
	messageBlock := [ :message | ]
]

{ #category : 'instance creation' }
RTCDataChannel class >> on: aChannel [

	^ self new channel: aChannel
]

{ #category : 'accessing' }
RTCDataChannel >> channel: aChannel [

	channel := aChannel.
	channel onmessage: [ :event | messageBlock value: event data ].
	^ self
]

{ #category : 'accessing' }
RTCDataChannel >> onMessage: aBlock [

	messageBlock := aBlock
]

{ #category : 'actions' }
RTCDataChannel >> send: aMessage [

	channel send: aMessage
]