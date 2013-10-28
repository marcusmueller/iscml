/*
 * Copyright 2010 Daniel Kurka
 * 
 * Licensed under the Apache License, Version 2.0 (the "License"); you may not
 * use this file except in compliance with the License. You may obtain a copy of
 * the License at
 * 
 * http://www.apache.org/licenses/LICENSE-2.0
 * 
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
 * WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
 * License for the specific language governing permissions and limitations under
 * the License.
 */
package com.googlecode.mgwt.examples.showcase.client;

import com.google.gwt.place.shared.PlaceHistoryMapper;
import com.google.gwt.place.shared.WithTokenizers;
import com.googlecode.mgwt.examples.showcase.client.activities.animation.AnimationPlace.AnimationPlaceTokenizer;
import com.googlecode.mgwt.examples.showcase.client.activities.animationdone.AnimationCubePlace;
import com.googlecode.mgwt.examples.showcase.client.activities.animationdone.AnimationDissolvePlace.AnimationDissolvePlaceTokenizer;
import com.googlecode.mgwt.examples.showcase.client.activities.animationdone.AnimationFadePlace.AnimationFadePlaceTokenizer;
import com.googlecode.mgwt.examples.showcase.client.activities.animationdone.AnimationFlipPlace.AnimationFlipPlaceTokenizer;
import com.googlecode.mgwt.examples.showcase.client.activities.animationdone.AnimationPopPlace.AnimationPopPlaceTokenizer;
import com.googlecode.mgwt.examples.showcase.client.activities.animationdone.AnimationSlideDownPlace.AnimationSlideDownPlaceTokenizer;
import com.googlecode.mgwt.examples.showcase.client.activities.animationdone.AnimationSlidePlace.AnimationSlidePlaceTokenizer;
import com.googlecode.mgwt.examples.showcase.client.activities.animationdone.AnimationSlideUpPlace.AnimationSlideUpPlaceTokenizer;
import com.googlecode.mgwt.examples.showcase.client.activities.animationdone.AnimationSwapPlace.AnimationSwapPlaceTokenizer;
import com.googlecode.mgwt.examples.showcase.client.activities.button.BCFunctionButtonPlace.BCFunctionButtonPlaceTokenizer;
import com.googlecode.mgwt.examples.showcase.client.activities.button.ButtonPlace.ButtonPlaceTokenizer;
import com.googlecode.mgwt.examples.showcase.client.activities.buttonbar.ButtonBarPlace.ButtonBarPlaceTokenizer;
import com.googlecode.mgwt.examples.showcase.client.activities.carousel.CarouselPlace;
import com.googlecode.mgwt.examples.showcase.client.activities.elements.ElementsPlace.ElementsPlaceTokenizer;
import com.googlecode.mgwt.examples.showcase.client.activities.forms.FormsPlace;
import com.googlecode.mgwt.examples.showcase.client.activities.gcell.GroupedCellListPlace;
import com.googlecode.mgwt.examples.showcase.client.activities.popup.PopupPlace.PopupPlaceTokenizer;
import com.googlecode.mgwt.examples.showcase.client.activities.progressbar.ProgressBarPlace.ProgressBarPlaceTokenizer;
import com.googlecode.mgwt.examples.showcase.client.activities.progressindicator.ProgressIndicatorPlace;
import com.googlecode.mgwt.examples.showcase.client.activities.pulltorefresh.PullToRefreshPlace;
import com.googlecode.mgwt.examples.showcase.client.activities.scrollwidget.ScrollWidgetPlace.ScrollWidgetPlaceTokenizer;
import com.googlecode.mgwt.examples.showcase.client.activities.searchbox.SearchBoxPlace.SearchBoxPlaceTokenizer;
import com.googlecode.mgwt.examples.showcase.client.activities.slider.SliderPlace.SliderPlaceTokenizer;
import com.googlecode.mgwt.examples.showcase.client.activities.tabbar.TabBarPlace.TabBarPlaceTokenizer;
import com.googlecode.mgwt.examples.showcase.client.custom.EnrollImgUploadPlace.EnrollImgUploadPlaceTokenizer;
import com.googlecode.mgwt.examples.showcase.client.custom.GenerateModelPlace.GenerateModelPlaceTokenizer;
import com.googlecode.mgwt.examples.showcase.client.custom.IdentifyImgUploadPlace.IdentifyImgUploadPlaceTokenizer;
import com.googlecode.mgwt.examples.showcase.client.custom.jobs.JobDetailsPlace.JobDetailsPlaceTokenizer;
import com.googlecode.mgwt.examples.showcase.client.custom.jobs.JobHistoryPlace.JobHistoryPlaceTokenizer;
import com.googlecode.mgwt.examples.showcase.client.places.HomePlace.HomePlaceTokenizer;
import com.googlecode.mgwt.examples.showcase.client.settings.ChangePasswordPlace.ChangePasswordPlaceTokenizer;

/**
 * @author Daniel Kurka
 * 
 */
@WithTokenizers({ HomePlaceTokenizer.class, /*UIPlaceTokenizer.class,*/ ScrollWidgetPlaceTokenizer.class, /*AboutPlaceTokenizer.class,*/ ButtonPlaceTokenizer.class, BCFunctionButtonPlaceTokenizer.class,  AnimationDissolvePlaceTokenizer.class,
	    EnrollImgUploadPlaceTokenizer.class, JobHistoryPlaceTokenizer.class, JobDetailsPlaceTokenizer.class, IdentifyImgUploadPlaceTokenizer.class, GenerateModelPlaceTokenizer.class, ChangePasswordPlaceTokenizer.class, AnimationFadePlaceTokenizer.class, AnimationFlipPlaceTokenizer.class, AnimationPlaceTokenizer.class, AnimationPopPlaceTokenizer.class, AnimationSlidePlaceTokenizer.class,
		AnimationSlideUpPlaceTokenizer.class, AnimationSwapPlaceTokenizer.class, AnimationSlideDownPlaceTokenizer.class, ButtonBarPlaceTokenizer.class, ElementsPlaceTokenizer.class, FormsPlace.Tokenizer.class, PopupPlaceTokenizer.class,
		ProgressBarPlaceTokenizer.class, SearchBoxPlaceTokenizer.class, SliderPlaceTokenizer.class, TabBarPlaceTokenizer.class, PullToRefreshPlace.Tokenizer.class, AnimationCubePlace.Tokenizer.class,
		ProgressIndicatorPlace.Tokenizer.class, CarouselPlace.Tokenizer.class, GroupedCellListPlace.Tokenizer.class })
public interface AppPlaceHistoryMapper extends PlaceHistoryMapper {
}
