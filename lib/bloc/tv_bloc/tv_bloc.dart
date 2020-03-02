import 'dart:async';

import 'package:MovieDB/model/credit.dart';
import 'package:MovieDB/model/tv_details.dart';
import 'package:MovieDB/model/tv_list_model.dart';
import 'package:MovieDB/model/video_details.dart';
import 'package:MovieDB/repository/tv_series_repository.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'tv_event.dart';
part 'tv_state.dart';

class TvBloc extends Bloc<TvEvent, TvState> {
  TVRepository tvRepository=TVRepository();

  @override
  TvState get initialState => TvInitial();

  @override
  Stream<TvState> mapEventToState(
    TvEvent event,
  ) async* {
    if (event is LoadTvEvent) {
      yield* _fetchTvState(event.type, event.id, event.currentPageIndex);
    }

    if (event is LoadMoreTvEvent) {
      yield* _fetchMoreTvState(
          event.type, event.id, event.currentPageIndex);
    }

    if (event is LoadTvDetailsEvent) {
      yield* _processTvDetailsState(
          event.id);
    }
  }

  Stream<TvState> _fetchTvState(
      TvCat type, int id, int currentPageIndex) async* {
    yield TvLoadingState();

    var tvs = await tvRepository.getTvShows(type, id, currentPageIndex);
    // print(type);

    if (tvs != null) {
      yield TvLoadedState(tvs: tvs);
    } else {
      yield TvErrorState();
    }
  }

  Stream<TvState> _fetchMoreTvState(
      TvCat type, int id, int currentPageIndex) async* {
    //     yield LoadingState();

    var tvs = await tvRepository.getTvShows(type, id, currentPageIndex);
    if (tvs != null) {
      yield MoreMoviesLoadedState(tvs: tvs);
    } else {
      yield TvErrorState();
    }
  }
  Stream<TvState> _processTvDetailsState(int id) async* {
    yield TvLoadingState();
    TvDetails tvDetails = await tvRepository.getTvDetails(id);
    var videoDetails = await tvRepository.getTvVideos(id);
    var similarTvs =
    await tvRepository.getTvShows(TvCat.Similar, id, 1);
    var tvCredit = await tvRepository.getTvCredits(id);

    yield TvDetailsReadyState(
        tvDetails: tvDetails,
        videoDetails: videoDetails,
        similarTvs: similarTvs,
        credit: tvCredit);
  }
}
