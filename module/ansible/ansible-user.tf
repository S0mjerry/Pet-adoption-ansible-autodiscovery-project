resource "aws_iam_user" "Jayz" {
    name = "ansible-user"
}
resource "aws_iam_access_key" "user-access-key" {
  user = aws_iam_user.Jayz.name
}
resource "aws_iam_group" "pet-groups" {
  name = "ansible-group"
}
resource "aws_iam_user_group_membership" "Jayz" {
  user = aws_iam_user.Jayz.name
  groups = [aws_iam_group.pet-groups.name]
}
resource "aws_iam_group_policy_attachment" "policy" {
  group = aws_iam_group.pet-groups.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2FullAccess"
}
