//
//  SubredditPostRow.swift
//  RedditOs
//
//  Created by Thomas Ricouard on 09/07/2020.
//

import SwiftUI
import Backend

struct SubredditPostRow: View, Equatable {
    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.postId == rhs.postId &&
            lhs.displayMode == rhs.displayMode
    }
    
    enum DisplayMode: String, CaseIterable {
        case compact = "Compact layout"
        case large = "Full detail layout"
        
        func symbol() -> String {
            switch self {
            case .compact: return "list.bullet"
            case .large: return "list.bullet.below.rectangle"
            }
        }
        
        func numberOfLines() -> Int?  {
            switch self {
            case .compact: return 3
            default: return nil
            }
        }
    }
    
    private let postId: String
    
    @StateObject var viewModel: PostViewModel
    @Binding var displayMode: DisplayMode
    
    @Environment(\.openURL) private var openURL
    
    init(post: SubredditPost, displayMode: Binding<DisplayMode>) {
        self.postId = post.id
        _viewModel = StateObject(wrappedValue: PostViewModel(post: post))
        _displayMode = displayMode
    }
    
    var body: some View {
        NavigationLink(destination: PostDetailView(viewModel: viewModel).equatable()) {
            HStack {
                VStack(alignment: .leading) {
                    HStack(alignment: .center, spacing: 8) {
                        PostVoteView(viewModel: viewModel)
                        if displayMode == .large {
                            SubredditPostThumbnailView(viewModel: viewModel)
                        }
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(viewModel.post.title)
                                .fontWeight(.bold)
                                .font(.body)
                                .lineLimit(displayMode.numberOfLines())
                                .foregroundColor(viewModel.post.visited ? .gray : nil)
                                .help(viewModel.post.title)
                            HStack {
                                if let richText = viewModel.post.linkFlairRichtext, !richText.isEmpty {
                                    FlairView(richText: richText,
                                              textColorHex: viewModel.post.linkFlairTextColor,
                                              backgroundColorHex: viewModel.post.linkFlairBackgroundColor,
                                              display: .normal)
                                }
                                if (viewModel.post.selftext == nil || viewModel.post.selftext?.isEmpty == true),
                                   displayMode == .large,
                                   let urlString = viewModel.post.url,
                                   let url = URL(string: urlString) {
                                    Link(destination: url) {
                                        Text(url.host ?? url.absoluteString)
                                            .lineLimit(1)
                                            .truncationMode(.tail)
                                    }
                                }
                            }
                            PostInfoView(post: viewModel.post, display: .vertical)
                        }
                    }
                }
                Spacer()
            }
        }
        .padding(.vertical, 8)
        .contextMenu {
            Button {
                viewModel.postVote(vote: .upvote)
            } label: { Text("Upvote") }
            Button {
                viewModel.postVote(vote: .downvote)
            } label: { Text("Downvote") }
            Button {
                viewModel.toggleSave()
            } label: { Text(viewModel.post.saved ? "Unsave": "Save") }
            Button {
                if let url = viewModel.post.redditURL {
                    openURL(url)
                }
            } label: { Text("Open in browser") }
            Button {
                if let url = viewModel.post.redditURL {
                    NSPasteboard.general.clearContents()
                    NSPasteboard.general.setString(url.absoluteString, forType: .string)
                }
                
            } label: { Text("Copy URL") }
        }
        Divider()
    }
}

struct SubredditPostRow_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            List {
                SubredditPostRow(post: static_listing, displayMode: .constant(.large))
                SubredditPostRow(post: static_listing, displayMode: .constant(.large))
                SubredditPostRow(post: static_listing, displayMode: .constant(.large))
                
                Divider()
                
                SubredditPostRow(post: static_listing, displayMode: .constant(.compact))
                SubredditPostRow(post: static_listing, displayMode: .constant(.compact))
                SubredditPostRow(post: static_listing, displayMode: .constant(.compact))
            }.frame(width: 500)
        }
    }
}
