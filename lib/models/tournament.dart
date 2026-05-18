enum TournamentStage {
  none('準備中'),
  district('地区大会'),
  prefectural('県大会'),
  koshien('甲子園'),
  champion('甲子園優勝');

  const TournamentStage(this.label);
  final String label;

  TournamentStage? get next => switch (this) {
        TournamentStage.none => TournamentStage.district,
        TournamentStage.district => TournamentStage.prefectural,
        TournamentStage.prefectural => TournamentStage.koshien,
        TournamentStage.koshien => TournamentStage.champion,
        TournamentStage.champion => null,
      };
}
