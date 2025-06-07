class FirebaseErrorTranslator {
  static String translate(String code) {
    switch (code) {
      case 'invalid-credential':
        return 'Credenciais inválidas. Verifique e-mail e senha.';
      case 'user-not-found':
        return 'Usuário não encontrado. Verifique o e-mail.';
      case 'wrong-password':
        return 'Senha incorreta. Tente novamente.';
      case 'email-already-in-use':
      case 'already-exists':
        return 'Este e-mail já está em uso por outra conta.';
      case 'invalid-email':
        return 'Formato de e-mail inválido.';
      case 'network-request-failed':
        return 'Sem conexão. Verifique sua internet.';
      default:
        return 'Ocorreu um erro inesperado. Tente novamente.';
    }
  }
}
