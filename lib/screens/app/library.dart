import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutters_of_hamelin/data/data.dart';
import 'package:flutters_of_hamelin/models/models.dart';
import 'package:flutters_of_hamelin/screens/playlist_form.dart';
import 'package:flutters_of_hamelin/services/database.dart';

class Library extends StatelessWidget {
  Library({Key? key}) : super(key: key);
  final auth = FirebaseAuth.instance;
  final db = FirebaseFirestore.instance;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          TextButton.icon(
              onPressed: () {
                FirebaseAuth.instance.signOut();
              },
              icon: const Icon(
                Icons.person_off,
                color: Colors.white,
              ),
              label: const Text(
                'Sign out',
                style: TextStyle(color: Colors.white),
              )),
        ],
        backgroundColor: Colors.black,
        title: const Text('Profile'),
      ),
      body: FutureBuilder<DocumentSnapshot>(
          future: db.collection('Users').doc(auth.currentUser!.uid).get(),
          builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
            if (snapshot.hasData) {
              AppUser user = AppUser.fromJson(snapshot.data!.data() as Map);
              return _buildScreen(user);
            } else {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
          }),
    );
  }
}

Widget _buildScreen(AppUser user) {
  TextStyle follStyle = const TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );
  TextStyle numStyle = const TextStyle(
    fontSize: 14,
    color: Colors.white,
  );
  return Column(
    children: [
      Container(
        decoration: BoxDecoration(
            image: DecorationImage(
                image: AssetImage(profile.banner), fit: BoxFit.fitWidth)),
        child: Column(
          children: [
            const SizedBox(height: 15),
            Text(
              user.username,
              style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
            const SizedBox(height: 15),
            CircleAvatar(
              backgroundImage: AssetImage(profile.avatar),
              radius: 50,
            ),
            const SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    Text(
                      "Followers",
                      style: follStyle,
                    ),
                    Text(
                      '${profile.followers}',
                      style: numStyle,
                    ),
                  ],
                ),
                Column(
                  children: [
                    Text(
                      "Following",
                      style: follStyle,
                    ),
                    Text(
                      '${profile.following}',
                      style: numStyle,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 15),
          ],
        ),
      ),
      const SizedBox(height: 15),
      // const _ArtistList(title: 'Artists'),
      // const SizedBox(height: 15),
      // const _GenreList(title: 'Genres'),
      const _PlaylistList(title: 'My Playlists'),
    ],
  );
}

// class _ArtistList extends StatelessWidget {
//   const _ArtistList({Key? key, required this.title}) : super(key: key);
//   final String title;
//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       mainAxisAlignment: MainAxisAlignment.start,
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 16.0),
//           child: Text(
//             title,
//             style: const TextStyle(
//               fontSize: 18,
//               fontWeight: FontWeight.w700,
//             ),
//           ),
//         ),
//         const SizedBox(
//           height: 8,
//         ),
//         SizedBox(
//           height: 100,
//           child: ListView.builder(
//             scrollDirection: Axis.horizontal,
//             itemCount: songList.length,
//             padding: const EdgeInsets.symmetric(horizontal: 16.0),
//             itemBuilder: (context, index) => Container(
//               margin: const EdgeInsets.symmetric(horizontal: 8.0),
//               width: 100,
//               decoration: BoxDecoration(
//                 shape: BoxShape.circle,
//                 image: DecorationImage(
//                     image: AssetImage(songList[index].img), fit: BoxFit.cover),
//               ),
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }

class _PlaylistList extends StatefulWidget {
  const _PlaylistList({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<_PlaylistList> createState() => _PlaylistListState();
}

class _PlaylistListState extends State<_PlaylistList> {
  final db = FirebaseFirestore.instance;
  void _showPlaylistPanel() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 60.0),
          child: const PlaylistForm(),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    DatabaseService db = DatabaseService();
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                Text(
                  widget.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Expanded(child: SizedBox()),
                TextButton.icon(
                  onPressed: () {
                    _showPlaylistPanel();
                  },
                  icon: const Icon(Icons.add, color: Colors.black),
                  label: const Text(
                    'Create Playlist',
                    style: TextStyle(color: Colors.black),
                  ),
                )
              ],
            ),
          ),
          const SizedBox(
            height: 8,
          ),
          Expanded(
            child: StreamBuilder(
              stream: db.playlists.snapshots(),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (!snapshot.hasData) {
                  return const Text('Something went wrong.');
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
                return ListView(
                  children:
                      snapshot.data!.docs.map((DocumentSnapshot document) {
                    Map<String, dynamic> data =
                        document.data()! as Map<String, dynamic>;
                    List list = data['songs'];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: PlaylistTile(
                        songId: list.isNotEmpty ? list[0] : null,
                        playlistTitle: data['name'],
                        playlistId: document.id,
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          )
        ],
      ),
    );
  }
}

class PlaylistTile extends StatefulWidget {
  const PlaylistTile(
      {Key? key,
      required this.songId,
      required this.playlistTitle,
      required this.playlistId})
      : super(key: key);
  final String? songId;
  final String playlistTitle;
  final String playlistId;
  @override
  State<PlaylistTile> createState() => _PlaylistTileState();
}

class _PlaylistTileState extends State<PlaylistTile> {
  DatabaseService db = DatabaseService();
  void _showAlertDialog(String playlistId) {
    String id = playlistId;
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Delete playlist'),
            content: const Text("This action can't be undone, are you sure?"),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('No')),
              TextButton(
                onPressed: () {
                  db.removePlaylistById(id);
                  Navigator.pop(context);
                },
                child: const Text('Yes'),
              ),
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    DatabaseService db = DatabaseService();
    return widget.songId == null || widget.songId == ""
        ? Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  color: Colors.grey,
                ),
                const SizedBox(
                  width: 8.0,
                ),
                Text(
                  widget.playlistTitle,
                  style: const TextStyle(fontSize: 18.0, color: Colors.black),
                ),
                const Expanded(child: SizedBox()),
                IconButton(
                  onPressed: () {
                    _showAlertDialog(widget.playlistId);
                  },
                  icon: const Icon(Icons.delete),
                ),
              ],
            ),
          )
        : FutureBuilder(
            future: db.getSongById(widget.songId!),
            builder: (BuildContext context, AsyncSnapshot<Song> snapshot) {
              if (snapshot.hasError) {
                return const Text("Something went wrong");
              }
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: GestureDetector(
                  onTap: () {},
                  child: Row(
                    children: [
                      SizedBox(
                        width: 50,
                        height: 50,
                        child: Image.network(snapshot.data!.img),
                      ),
                      const SizedBox(
                        width: 8.0,
                      ),
                      Text(
                        widget.playlistTitle,
                        style: const TextStyle(
                            fontSize: 18.0, color: Colors.black),
                      ),
                      const Expanded(child: SizedBox()),
                      IconButton(
                        onPressed: () {
                          _showAlertDialog(widget.playlistId);
                        },
                        icon: const Icon(Icons.delete),
                      ),
                    ],
                  ),
                ),
              );
            });
  }
}
