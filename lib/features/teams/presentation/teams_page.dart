import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tasks/features/teams/domain/entities/team_entity.dart';
import 'package:tasks/features/teams/presentation/cubit/teams_cubit.dart';
import '../../Auth/presentation/EmailInputPage.dart';
import '../../Auth/presentation/RegisterDialog.dart';
import '../../Auth/presentation/cubit/auth_cubit.dart';
import 'TeamDetailsPage.dart';
import 'cubit/ProfilesCubit.dart';
import 'cubit/members_cubit.dart';

class TeamsPage extends StatelessWidget {
  const TeamsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => ProfilesCubit()..loadProfiles()),
        BlocProvider(create: (_) => TeamsCubit()..loadTeams()), // مثال
      ],
      child: DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            title: const Text("Teams & Members"),
            bottom: const TabBar(
              tabs: [Tab(text: "Teams"), Tab(text: "Members")],
            ),
          ),
          body: const TabBarView(children: [_TeamsTab(), _MembersTab()]),
        ),
      ),
    );
  }
}

// تبويب الفرق
class _TeamsTab extends StatelessWidget {
  const _TeamsTab();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: BlocBuilder<TeamsCubit, List<TeamEntity>>(
        builder: (context, teams) {
          if (teams.isEmpty) {
            return const Center(
              child: Text(
                "No teams yet",
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: teams.length,
            itemBuilder: (context, index) {
              final team = teams[index];
              return Card(
                elevation: 3,
                margin: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (_) => BlocProvider(
                              create:
                                  (_) => MembersCubit()..loadMembers(team.id),
                              child: TeamDetailsPage(team: team),
                            ),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      children: [
                        // Team avatar icon
                        CircleAvatar(
                          backgroundColor: Colors.blue.shade100,
                          child: const Icon(Icons.group, color: Colors.blue),
                        ),
                        const SizedBox(width: 12),

                        // Team name + description
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                team.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                team.description ?? "No description",
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),

                        // Actions
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              tooltip: "Delete team",
                              onPressed: () {
                                _showDeleteDialog(context, team);
                              },
                            ),
                            const Icon(
                              Icons.arrow_forward_ios,
                              size: 16,
                              color: Colors.grey,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddTeamDialog(context),
        icon: const Icon(Icons.add),
        label: const Text("New Team"),
        backgroundColor: Theme.of(context).primaryColor,
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, TeamEntity team) {
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            title: const Text("Delete Team"),
            content: Text("Are you sure you want to delete '${team.name}'?"),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text("Cancel"),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                onPressed: () {
                  context.read<TeamsCubit>().deleteTeam(team.id);
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Team '${team.name}' deleted"),
                      backgroundColor: Colors.red.shade400,
                    ),
                  );
                },
                child: const Text("Delete"),
              ),
            ],
          ),
    );
  }

  void _showAddTeamDialog(BuildContext context) {
    final nameController = TextEditingController();
    final descController = TextEditingController();

    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            title: const Text("Add Team"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: "Team Name",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descController,
                  decoration: const InputDecoration(
                    labelText: "Description",
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text("Cancel"),
              ),
              ElevatedButton(
                onPressed: () {
                  context.read<TeamsCubit>().addTeam(
                    nameController.text,
                    descController.text.isEmpty ? null : descController.text,
                  );
                  Navigator.pop(ctx);
                },
                child: const Text("Add"),
              ),
            ],
          ),
    );
  }
}

class EditUserDialog extends StatefulWidget {
  final Map<String, dynamic> user;

  const EditUserDialog({required this.user, super.key});

  @override
  State<EditUserDialog> createState() => _EditUserDialogState();
}

class _EditUserDialogState extends State<EditUserDialog> {
  late TextEditingController _usernameController;
  late String _role;

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController(
      text: widget.user['username'] ?? "",
    );
    _role = widget.user['role'] ?? "member";
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Edit User"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _usernameController,
            decoration: const InputDecoration(labelText: "Username"),
          ),
          DropdownButtonFormField<String>(
            value: _role,
            items: const [
              DropdownMenuItem(value: "admin", child: Text("Admin")),
              // DropdownMenuItem(value: "manager", child: Text("Manager")),
              DropdownMenuItem(value: "member", child: Text("Member")),
            ],
            onChanged: (v) => setState(() => _role = v ?? "member"),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text("Cancel"),
        ),
        ElevatedButton(
          onPressed: () async {
            try {
              await Supabase.instance.client
                  .from('profiles')
                  .update({'username': _usernameController.text, 'role': _role})
                  .eq('id', widget.user['id']);
              Navigator.pop(context, true);
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("Error updating user: $e"),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          child: const Text("Save"),
        ),
      ],
    );
  }
}

class _MembersTab extends StatefulWidget {
  const _MembersTab();

  @override
  State<_MembersTab> createState() => _MembersTabState();
}

class _MembersTabState extends State<_MembersTab>
    with AutomaticKeepAliveClientMixin {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _roleFilter = 'all';
  String _sortBy = 'username';
  bool _sortAscending = true;

  @override
  void initState() {
    super.initState();
    context.read<ProfilesCubit>().loadProfiles();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> _filterAndSortProfiles(
    List<Map<String, dynamic>> profiles,
  ) {
    List<Map<String, dynamic>> filtered =
        profiles.where((user) {
          final matchesSearch =
              _searchQuery.isEmpty ||
              (user['username']?.toString().toLowerCase().contains(
                    _searchQuery,
                  ) ??
                  false) ||
              (user['email']?.toString().toLowerCase().contains(_searchQuery) ??
                  false);

          final matchesRole =
              _roleFilter == 'all' || (user['role']?.toString() == _roleFilter);

          return matchesSearch && matchesRole;
        }).toList();

    filtered.sort((a, b) {
      int comparison = 0;
      switch (_sortBy) {
        case 'username':
          comparison = (a['username'] ?? '').compareTo(b['username'] ?? '');
          break;
        case 'email':
          comparison = (a['email'] ?? '').compareTo(b['email'] ?? '');
          break;
        case 'role':
          comparison = (a['role'] ?? '').compareTo(b['role'] ?? '');
          break;
        case 'created_at':
          final dateA =
              a['created_at'] != null
                  ? DateTime.parse(a['created_at'])
                  : DateTime(0);
          final dateB =
              b['created_at'] != null
                  ? DateTime.parse(b['created_at'])
                  : DateTime(0);
          comparison = dateA.compareTo(dateB);
          break;
      }
      return _sortAscending ? comparison : -comparison;
    });

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                // Search bar expands to fill available space
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search members...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey[100],
                    ),
                    onChanged: (_) {
                      setState(() {}); // Trigger UI refresh on typing
                    },
                  ),
                ),

                const SizedBox(width: 8),

                // Filter button
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.filter_list),
                    onPressed: _showFilterDialog,
                    tooltip: 'Filter and Sort',
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: BlocBuilder<ProfilesCubit, List<Map<String, dynamic>>>(
              builder: (context, profiles) {
                if (profiles.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.group, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          "No members found",
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                      ],
                    ),
                  );
                }

                final filteredProfiles = _filterAndSortProfiles(profiles);

                if (filteredProfiles.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          "No members match your search",
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: filteredProfiles.length,
                  itemBuilder: (context, index) {
                    final user = filteredProfiles[index];

                    final role = user['role'] ?? 'member';
                    final createdAt =
                        user['created_at'] != null
                            ? DateTime.parse(user['created_at'])
                            : null;
                    final isVerified = user['is_verified'] == true;

                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      elevation: 2,
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: _getRoleColor(role),
                          child: const Icon(Icons.person, color: Colors.white),
                        ),
                        title: Row(
                          children: [
                            Expanded(
                              child: Text(
                                user['username'] ?? "No username",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: _getRoleColor(role),
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            isVerified
                                ? const Icon(
                                  Icons.verified,
                                  color: Colors.blue,
                                  size: 18,
                                )
                                : const Icon(
                                  Icons.error_outline,
                                  color: Colors.orange,
                                  size: 18,
                                ),
                          ],
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user['email'] ?? "No email",
                              style: const TextStyle(fontSize: 12),
                            ),
                            if (user['phone'] != null)
                              Text(
                                "Phone: ${user['phone']}",
                                style: const TextStyle(fontSize: 12),
                              ),
                            if (createdAt != null)
                              Text(
                                "Joined: ${_formatDate(createdAt)}",
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey,
                                ),
                              ),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Chip(
                              label: Text(
                                role.toUpperCase(),
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              backgroundColor: _getRoleColor(role),
                            ),
                            PopupMenuButton(
                              icon: const Icon(Icons.more_vert),
                              itemBuilder:
                                  (context) => [
                                    const PopupMenuItem(
                                      value: 'edit',
                                      child: ListTile(
                                        leading: Icon(Icons.edit),
                                        title: Text('Edit User'),
                                      ),
                                    ),
                                    const PopupMenuItem(
                                      value: 'delete',
                                      child: ListTile(
                                        leading: Icon(Icons.delete),
                                        title: Text('Delete User'),
                                      ),
                                    ),
                                    const PopupMenuItem(
                                      value: 'view_teams',
                                      child: ListTile(
                                        leading: Icon(Icons.group),
                                        title: Text('View Teams'),
                                      ),
                                    ),
                                    const PopupMenuItem(
                                      value: 'verifie',
                                      child: ListTile(
                                        leading: Icon(Icons.key),
                                        title: Text('verifie'),
                                      ),
                                    ),
                                  ],
                              onSelected: (value) async {
                                if (value == 'edit') {
                                  final updated = await showDialog(
                                    context: context,
                                    builder: (_) => EditUserDialog(user: user),
                                  );
                                  if (updated == true) {
                                    context
                                        .read<ProfilesCubit>()
                                        .loadProfiles();
                                  }
                                } else if (value == 'delete') {
                                  // TODO: delete user function
                                  final confirm = await showDialog<bool>(
                                    context: context,
                                    builder:
                                        (_) => AlertDialog(
                                          title: const Text("Confirm Delete"),
                                          content: Text(
                                            "Are you sure you want to delete ${user['username']}?",
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed:
                                                  () => Navigator.pop(
                                                    context,
                                                    false,
                                                  ),
                                              child: const Text("Cancel"),
                                            ),
                                            ElevatedButton(
                                              onPressed:
                                                  () => Navigator.pop(
                                                    context,
                                                    true,
                                                  ),
                                              child: const Text("Delete"),
                                            ),
                                          ],
                                        ),
                                  );
                                  if (confirm == true) {
                                    context.read<ProfilesCubit>().deleteUser(
                                      user['id'],
                                    );
                                  }
                                } else if (value == 'view_teams') {
                                  _showUserTeams(context, user);
                                } else if (value == 'verifie') {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => EmailInputPage(email : user['email'],),
                                    ),
                                  );
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          //   Navigator.push(
          //     context,
          //     MaterialPageRoute(
          //       builder: (_) => BlocProvider.value(
          //         value: context.read<AuthCubit>(),
          //         child: const RegisterDialog(),
          //       ),
          //     ),
          //   ).then((_) {
          //     context.read<ProfilesCubit>().loadProfiles();
          //   });

          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (_) => BlocProvider.value(
                    value: context.read<AuthCubit>(),
                    child: const RegisterDialog(),
                  ),
            ),
          );
        },
        child: const Icon(Icons.person_add),
        backgroundColor: Colors.blue[700],
      ),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder:
          (context) => StatefulBuilder(
            builder:
                (context, setState) => AlertDialog(
                  title: const Text('Filter & Sort Members'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Filter by Role:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      DropdownButtonFormField<String>(
                        value: _roleFilter,
                        items: const [
                          DropdownMenuItem(
                            value: 'all',
                            child: Text('All Roles'),
                          ),
                          DropdownMenuItem(
                            value: 'admin',
                            child: Text('Admin'),
                          ),
                          DropdownMenuItem(
                            value: 'member',
                            child: Text('Member'),
                          ),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _roleFilter = value ?? 'all';
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Sort by:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      DropdownButtonFormField<String>(
                        value: _sortBy,
                        items: const [
                          DropdownMenuItem(
                            value: 'username',
                            child: Text('Username'),
                          ),
                          DropdownMenuItem(
                            value: 'email',
                            child: Text('Email'),
                          ),
                          DropdownMenuItem(value: 'role', child: Text('Role')),
                          DropdownMenuItem(
                            value: 'created_at',
                            child: Text('Join Date'),
                          ),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _sortBy = value ?? 'username';
                          });
                        },
                      ),
                      CheckboxListTile(
                        title: const Text('Ascending Order'),
                        value: _sortAscending,
                        onChanged: (value) {
                          setState(() {
                            _sortAscending = value ?? true;
                          });
                        },
                      ),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _roleFilter = 'all';
                          _sortBy = 'username';
                          _sortAscending = true;
                        });
                      },
                      child: const Text('Reset'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        setState(() {});
                      },
                      child: const Text('Apply'),
                    ),
                  ],
                ),
          ),
    );
  }

  Future<void> _showUserTeams(
    BuildContext context,
    Map<String, dynamic> user,
  ) async {
    try {
      final response =
          await Supabase.instance.client
              .from('team_members')
              .select('team_id, teams!inner(name)')
              .eq('user_id', user['id'])
              .execute();

      if (response.data != null) {
        final teams =
            (response.data as List)
                .map(
                  (e) =>
                      e['teams'] != null
                          ? (e['teams'] as Map<String, dynamic>)['name']
                              as String
                          : 'Unknown Team',
                )
                .toList();

        showDialog(
          context: context,
          builder:
              (context) => AlertDialog(
                title: Text("${user['username']}'s Teams"),
                content:
                    teams.isNotEmpty
                        ? Column(
                          mainAxisSize: MainAxisSize.min,
                          children:
                              teams
                                  .map(
                                    (team) => ListTile(
                                      leading: const Icon(Icons.group),
                                      title: Text(team),
                                    ),
                                  )
                                  .toList(),
                        )
                        : const Text('This user is not in any teams.'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Close'),
                  ),
                ],
              ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error loading teams: $e')));
    }
  }

  Future<void> _promoteToAdmin(
    BuildContext context,
    Map<String, dynamic> user,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Promote to Admin'),
            content: Text(
              'Are you sure you want to make ${user['username']} an admin?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Promote'),
              ),
            ],
          ),
    );

    if (confirmed == true) {
      try {
        await Supabase.instance.client
            .from('profiles')
            .update({'role': 'admin'})
            .eq('id', user['id'])
            .execute();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${user['username']} is now an admin!')),
        );

        context.read<ProfilesCubit>().loadProfiles();
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error promoting user: $e')));
      }
    }
  }

  Color _getRoleColor(String role) {
    switch (role) {
      case 'admin':
        return Colors.red;
      case 'manager':
        return Colors.orange;
      case 'member':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  bool get wantKeepAlive => true;
}
