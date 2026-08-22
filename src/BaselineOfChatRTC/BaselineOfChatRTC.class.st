Class {
	#name : 'BaselineOfChatRTC',
	#superclass : 'BaselineOf',
	#category : 'BaselineOfChatRTC',
	#package : 'BaselineOfChatRTC'
}

{ #category : 'baselines' }
BaselineOfChatRTC >> baseline: spec [

	<baseline>
	spec for: #common do: [
		spec
			baseline: 'Camping'
			with: [ spec repository: 'github://mattonem/WildCamping' ].

			spec package: #ChatRTC with: [ spec requires: #( Camping ) ].
			spec package: #'ChatRTC-DataChannel'.
			spec package: #'ChatRTC-Core'.
			spec package: #'ChatRTC-RTCConnection' with: [
				spec requires: #( ChatRTC 'ChatRTC-DataChannel' 'ChatRTC-Core') ].
			spec package: #'ChatRTC-UI' with: [
				spec requires: #( ChatRTC 'ChatRTC-RTCConnection' 'ChatRTC-Core') ] ]
]
