//
//  ContentView.swift
//  BetterRest
//
//  Created by Lucas Pennice on 08/02/2024.
//
import CoreML
import SwiftUI


struct ContentView: View {
    static var defaultWakeTime: Date {
        var components = DateComponents()
        components.hour = 7
        components.minute = 0
        
        return Calendar.current.date(from: components) ?? .now
    }

    @State private var wakeUp = defaultWakeTime
    @State private var sleepAmount = 8.0
    @State private var coffeeAmount = 1
    
    @State private var alert : (String, String) = ("Title", "Message")
    @State private var showAlert = false
    

    
    var body: some View {
        NavigationStack{
            Form{
                
                VStack (alignment: .leading){
                    Text("When do you want to wake up?")
                        .font(.headline)
                    
                    DatePicker("Wake up time", selection: $wakeUp, displayedComponents: .hourAndMinute)
                }
                
                VStack (alignment: .leading){
                    Text("You want to sleep ^[\(sleepAmount.formatted()) hour](inflect: true)")
                        .font(.headline)
                    
                    Stepper("How many hours to sleep", value: $sleepAmount, in: 4...12, step: 0.25)
                }
                
                VStack (alignment: .leading){
                    Text("I drank  \(coffeeAmount) coffee cups today")
                        .font(.headline)
                    
                    Stepper("^[\(coffeeAmount) cup](inflect: true)", value: $coffeeAmount, in: 0...20)
                }
            }

            .navigationTitle("BetterRest")
            .toolbar{
                Button("Calculate", action: calculateBedtime)
            }
            .alert(alert.0, isPresented: $showAlert){
                Text(alert.1)
                Button("Ok"){}
            }
        }
    }
    
    func calculateBedtime(){
        do{
            let config = MLModelConfiguration()
            let model = try SleepCalculator(configuration: config)
            
            let components = Calendar.current.dateComponents([.hour,.minute], from: wakeUp)
            let hourInSeconds = (components.hour ?? 0) * 60 * 60
            let minuteInSeconds = (components.minute ?? 0) * 60
            
            let prediction = try model.prediction(wake: Int64(hourInSeconds + minuteInSeconds), estimatedSleep: sleepAmount, coffee: Int64(coffeeAmount))
            
            let sleepTime = wakeUp - prediction.actualSleep
            
            alert = ("Success" ,"Your ideal bedtime is \(sleepTime.formatted(date:.omitted, time:.shortened))")
        } catch {
            alert = ("Error" ,"Sorry, there was a problem calculating your bedtime")
        }
            showAlert = true
    }
    
}

#Preview {
    ContentView()
}
