resource "aws_iam_user" "jayz" {
    name = "ansible-user"
}
resource "aws_iam_access_key" "user-access-key" {
  user = aws_iam_user.jayz.name
}
resource "aws_iam_group" "pet-group" {
  name = "ansible-group"
}
resource "aws_iam_user_group_membership" "jayz" {
  user = aws_iam_user.jayz.name
  groups = [aws_iam_group.pet-group.name]
}
resource "aws_iam_group_policy_attachment" "policy" {
  group = aws_iam_group.pet-group.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2FullAccess"
}
