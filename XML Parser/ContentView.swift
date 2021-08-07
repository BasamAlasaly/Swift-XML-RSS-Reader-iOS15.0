//
//  ContentView.swift
//  XML Parsing
//
//  Created by Basam Alasaly on 8/6/21.
//
import SwiftUI
import SWXMLHash

//Identifiable class for List
class Item: Identifiable
{
    var title = ""
    var url = ""
    var pubDate = Date()
}

struct ContentView: View {
    @State var channelName = ""
    @State var channelURL = ""
    @State var imageURL = ""
    @State var newsItems = [Item]()
    
    var body: some View {
        VStack{
            //Channel Information
            Text("\(channelName)")
                .font(.system(size: 16))
                .bold()
            Text("\(channelURL)")
            
            #warning("This is new in iOS 15 to load an image asynchronously from a URL")
            AsyncImage(url: URL(string: imageURL))
                .frame(height: 40)
            
            //List of News Items
            List(newsItems){ item in
                VStack(alignment: .leading){
                    Text("\(item.title)")
                        .bold()
                    Text("\(item.pubDate)")
                        .italic()
                        .font(.system(size: 14))
                }
                .onTapGesture {
                    UIApplication.shared.open(URL(string: item.url)!)
                }
            }
        }.onAppear(){
            //Function to retrieve and parse XML data
            loadData()
        }
    }
    
    func loadData(){
        let url = NSURL(string: "https://www.nytimes.com/svc/collections/v1/publish/https://www.nytimes.com/section/world/rss.xml")

        let task = URLSession.shared.dataTask(with: url! as URL) {(data, response, error) in
            if data != nil
            {
                let feed=NSString(data: data!, encoding: String.Encoding.utf8.rawValue)! as String
                let xml = SWXMLHash.parse(feed)
                
                channelName = xml["rss"]["channel"]["title"].element!.text
                channelURL = xml["rss"]["channel"]["link"].element!.text
                imageURL = xml["rss"]["channel"]["image"]["url"].element!.text

                for elem in xml["rss"]["channel"]["item"].all
                {
                    let item = Item()
                    item.title = elem["title"].element!.text
                    item.url = elem["link"].element!.text
                    item.pubDate = cleanDate(date: elem["pubDate"].element!.text)
                    newsItems.append(item)
                }
            }
        }
        task.resume()
    }

    func cleanDate(date: String) -> Date
    {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "E, d MMM yyyy HH:mm:ss Z"
        let pubDate = dateFormatter.date(from:date)!
        return pubDate
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
