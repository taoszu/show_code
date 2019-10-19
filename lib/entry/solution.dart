class Solution {

  Solution(this.name, this.sha, {this.ignoreSha = false});

  final String name;
  final String sha;
  final bool ignoreSha; // 忽略sha 直接使用cache

}