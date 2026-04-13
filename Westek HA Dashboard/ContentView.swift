import SwiftUI
import Combine
import CocoaMQTT

let mqttBroker = "172.16.100.11"
let mqttPort: UInt16 = 1883

class MQTTManager: NSObject, ObservableObject, CocoaMQTTDelegate {
    var mqtt: CocoaMQTT!
    @Published var lampState: Bool = false
    @Published var partyState: Bool = false

    override init() {
        super.init()
        let clientID = "WesTekDashboard-\(Int.random(in: 1000...9999))"
        mqtt = CocoaMQTT(clientID: clientID, host: mqttBroker, port: mqttPort)
        mqtt.username = "mosquitto"
        mqtt.password = "socius"
        mqtt.delegate = self
        _ = mqtt.connect()
    }

    nonisolated func mqtt(_ mqtt: CocoaMQTT, didConnectAck ack: CocoaMQTTConnAck) {
        guard ack == .accept else { return }
        mqtt.subscribe("stat/sonoff/office/lamp/POWER")
        mqtt.subscribe("stat/sonoff/office/partylights/POWER")
        // Query current state
        mqtt.publish("cmnd/sonoff/office/lamp/POWER", withString: "")
        mqtt.publish("cmnd/sonoff/office/partylights/POWER", withString: "")
    }

    nonisolated func mqtt(_ mqtt: CocoaMQTT, didReceiveMessage message: CocoaMQTTMessage, id: UInt16) {
        let payload = message.string ?? ""
        let topic = message.topic
        DispatchQueue.main.async {
            if topic == "stat/sonoff/office/lamp/POWER" {
                self.lampState = payload == "ON"
            }
            if topic == "stat/sonoff/office/partylights/POWER" {
                self.partyState = payload == "ON"
            }
        }
    }

    func toggle(topic: String, state: Bool) {
        mqtt.publish(topic, withString: state ? "ON" : "OFF")
    }

    // Required delegate stubs
    nonisolated func mqttDidDisconnect(_ mqtt: CocoaMQTT, withError err: Error?) {}
    nonisolated func mqtt(_ mqtt: CocoaMQTT, didPublishMessage message: CocoaMQTTMessage, id: UInt16) {}
    nonisolated func mqtt(_ mqtt: CocoaMQTT, didPublishAck id: UInt16) {}
    nonisolated func mqtt(_ mqtt: CocoaMQTT, didSubscribeTopics success: NSDictionary, failed: [String]) {}
    nonisolated func mqtt(_ mqtt: CocoaMQTT, didUnsubscribeTopics topics: [String]) {}
    nonisolated func mqttDidPing(_ mqtt: CocoaMQTT) {}
    nonisolated func mqttDidReceivePong(_ mqtt: CocoaMQTT) {}
}

struct ContentView: View {
    @StateObject var mqttManager = MQTTManager()

    var body: some View {
        VStack(spacing: 16) {
            Text("WesTek Office")
                .font(.headline)
                .padding(.top)

            Divider()

            HStack {
                Text("Lamp")
                Spacer()
                Circle()
                    .fill(mqttManager.lampState ? .green : .red)
                    .frame(width: 12, height: 12)
                    .shadow(color: mqttManager.lampState ? .green : .red, radius: 4)
            }
            .padding(.horizontal)
            .contentShape(Rectangle())
            .onTapGesture {
                let newValue = !mqttManager.lampState
                mqttManager.lampState = newValue
                mqttManager.toggle(topic: "cmnd/sonoff/office/lamp/power", state: newValue)
            }

            HStack {
                Text("Party Lights")
                Spacer()
                Circle()
                    .fill(mqttManager.partyState ? .green : .red)
                    .frame(width: 12, height: 12)
                    .shadow(color: mqttManager.partyState ? .green : .red, radius: 4)
            }
            .padding(.horizontal)
            .contentShape(Rectangle())
            .onTapGesture {
                let newValue = !mqttManager.partyState
                mqttManager.partyState = newValue
                mqttManager.toggle(topic: "cmnd/sonoff/office/partylights/power", state: newValue)
            }

            Spacer()
        }
        .frame(width: 300, height: 200)
    }
}

