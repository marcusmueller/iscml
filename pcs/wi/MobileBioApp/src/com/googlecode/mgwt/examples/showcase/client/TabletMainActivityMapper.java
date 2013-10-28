package com.googlecode.mgwt.examples.showcase.client;

import com.google.gwt.activity.shared.Activity;
import com.google.gwt.activity.shared.ActivityMapper;
import com.google.gwt.place.shared.Place;
import com.googlecode.mgwt.examples.showcase.client.activities.animation.AnimationPlace;
import com.googlecode.mgwt.examples.showcase.client.activities.animationdone.AnimationCubePlace;
import com.googlecode.mgwt.examples.showcase.client.activities.animationdone.AnimationDissolvePlace;
import com.googlecode.mgwt.examples.showcase.client.activities.animationdone.AnimationDoneActivity;
import com.googlecode.mgwt.examples.showcase.client.activities.animationdone.AnimationFadePlace;
import com.googlecode.mgwt.examples.showcase.client.activities.animationdone.AnimationFlipPlace;
import com.googlecode.mgwt.examples.showcase.client.activities.animationdone.AnimationPopPlace;
import com.googlecode.mgwt.examples.showcase.client.activities.animationdone.AnimationSlideDownPlace;
import com.googlecode.mgwt.examples.showcase.client.activities.animationdone.AnimationSlidePlace;
import com.googlecode.mgwt.examples.showcase.client.activities.animationdone.AnimationSlideUpPlace;
import com.googlecode.mgwt.examples.showcase.client.activities.animationdone.AnimationSwapPlace;
import com.googlecode.mgwt.examples.showcase.client.activities.button.BCFunctionButtonActivity;
import com.googlecode.mgwt.examples.showcase.client.activities.button.BCFunctionButtonPlace;
import com.googlecode.mgwt.examples.showcase.client.activities.button.ButtonActivity;
import com.googlecode.mgwt.examples.showcase.client.activities.button.ButtonPlace;
import com.googlecode.mgwt.examples.showcase.client.activities.buttonbar.ButtonBarActivity;
import com.googlecode.mgwt.examples.showcase.client.activities.buttonbar.ButtonBarPlace;
import com.googlecode.mgwt.examples.showcase.client.activities.carousel.CarouselActivity;
import com.googlecode.mgwt.examples.showcase.client.activities.carousel.CarouselPlace;
import com.googlecode.mgwt.examples.showcase.client.activities.elements.ElementsActivity;
import com.googlecode.mgwt.examples.showcase.client.activities.elements.ElementsPlace;
import com.googlecode.mgwt.examples.showcase.client.activities.forms.FormsActivity;
import com.googlecode.mgwt.examples.showcase.client.activities.forms.FormsPlace;
import com.googlecode.mgwt.examples.showcase.client.activities.gcell.GroupedCellListActivity;
import com.googlecode.mgwt.examples.showcase.client.activities.gcell.GroupedCellListPlace;
import com.googlecode.mgwt.examples.showcase.client.activities.popup.PopupActivity;
import com.googlecode.mgwt.examples.showcase.client.activities.popup.PopupPlace;
import com.googlecode.mgwt.examples.showcase.client.activities.progressbar.ProgressBarActivity;
import com.googlecode.mgwt.examples.showcase.client.activities.progressbar.ProgressBarPlace;
import com.googlecode.mgwt.examples.showcase.client.activities.progressindicator.ProgressIndicatorActivity;
import com.googlecode.mgwt.examples.showcase.client.activities.progressindicator.ProgressIndicatorPlace;
import com.googlecode.mgwt.examples.showcase.client.activities.pulltorefresh.PullToRefreshActivity;
import com.googlecode.mgwt.examples.showcase.client.activities.pulltorefresh.PullToRefreshPlace;
import com.googlecode.mgwt.examples.showcase.client.activities.scrollwidget.ScrollWidgetActivity;
import com.googlecode.mgwt.examples.showcase.client.activities.scrollwidget.ScrollWidgetPlace;
import com.googlecode.mgwt.examples.showcase.client.activities.searchbox.SearchBoxActivity;
import com.googlecode.mgwt.examples.showcase.client.activities.searchbox.SearchBoxPlace;
import com.googlecode.mgwt.examples.showcase.client.activities.slider.SliderActivity;
import com.googlecode.mgwt.examples.showcase.client.activities.slider.SliderPlace;
import com.googlecode.mgwt.examples.showcase.client.activities.tabbar.TabBarActivity;
import com.googlecode.mgwt.examples.showcase.client.activities.tabbar.TabBarPlace;
import com.googlecode.mgwt.examples.showcase.client.custom.EnrollImgUploadActivity;
import com.googlecode.mgwt.examples.showcase.client.custom.EnrollImgUploadPlace;
import com.googlecode.mgwt.examples.showcase.client.custom.GenerateModelActivity;
import com.googlecode.mgwt.examples.showcase.client.custom.GenerateModelPlace;
import com.googlecode.mgwt.examples.showcase.client.custom.IdentifyImgUploadActivity;
import com.googlecode.mgwt.examples.showcase.client.custom.IdentifyImgUploadPlace;
import com.googlecode.mgwt.examples.showcase.client.custom.jobs.JobDetailsActivity;
import com.googlecode.mgwt.examples.showcase.client.custom.jobs.JobDetailsPlace;
import com.googlecode.mgwt.examples.showcase.client.custom.jobs.JobHistoryActivity;
import com.googlecode.mgwt.examples.showcase.client.custom.jobs.JobHistoryPlace;
import com.googlecode.mgwt.examples.showcase.client.places.HomePlace;
import com.googlecode.mgwt.examples.showcase.client.settings.ChangePasswordActivity;
import com.googlecode.mgwt.examples.showcase.client.settings.ChangePasswordPlace;

public class TabletMainActivityMapper implements ActivityMapper {

	private final ClientFactory clientFactory;

	private Place lastPlace;

	public TabletMainActivityMapper(ClientFactory clientFactory) {
		this.clientFactory = clientFactory;

	}

	@Override
	public Activity getActivity(Place place) {
		Activity activity = getActivity(lastPlace, place);
		lastPlace = place;
		return activity;

	}

	/*private AboutActivity aboutActivity;

	private AboutActivity getAboutActivity() {
		if (aboutActivity == null) {
			aboutActivity = new AboutActivity(clientFactory);
		}

		return aboutActivity;
	}*/

	private Activity getActivity(Place lastPlace, Place newPlace) {
		/*if (newPlace instanceof HomePlace) {
			return getAboutActivity();
		}

		if (newPlace instanceof AboutPlace) {
			return getAboutActivity();
		}

		if (newPlace instanceof UIPlace) {
			return getAboutActivity();
		}*/

		if (newPlace instanceof ScrollWidgetPlace) {
			return new ScrollWidgetActivity(clientFactory);
		}

		if (newPlace instanceof ElementsPlace) {
			return new ElementsActivity(clientFactory);
		}

		if (newPlace instanceof FormsPlace) {
			return new FormsActivity(clientFactory);
		}

		if (newPlace instanceof ButtonBarPlace) {
			return new ButtonBarActivity(clientFactory);
		}

		if (newPlace instanceof SearchBoxPlace) {
			return new SearchBoxActivity(clientFactory);
		}

		if (newPlace instanceof TabBarPlace) {
			return new TabBarActivity(clientFactory);
		}

		if (newPlace instanceof ButtonPlace) {
			return new ButtonActivity(clientFactory);
		}
		
		if (newPlace instanceof BCFunctionButtonPlace) {
			return new BCFunctionButtonActivity(clientFactory);
		}
		
		if (newPlace instanceof EnrollImgUploadPlace) {
			return new EnrollImgUploadActivity(clientFactory);
		}
		
		if (newPlace instanceof JobHistoryPlace) {
			return new JobHistoryActivity(clientFactory);
		}
		
		if (newPlace instanceof JobDetailsPlace) {
			return new JobDetailsActivity(clientFactory);
		}
		
		if (newPlace instanceof IdentifyImgUploadPlace) {
			return new IdentifyImgUploadActivity(clientFactory);
		}
		
		if (newPlace instanceof GenerateModelPlace) {
			return new GenerateModelActivity(clientFactory);
		}
		
		if (newPlace instanceof ChangePasswordPlace) {
			return new ChangePasswordActivity(clientFactory);
		}

		if (newPlace instanceof PopupPlace) {
			return new PopupActivity(clientFactory);
		}

		if (newPlace instanceof ProgressBarPlace) {
			return new ProgressBarActivity(clientFactory);
		}

		if (newPlace instanceof ProgressIndicatorPlace) {
			return new ProgressIndicatorActivity(clientFactory);
		}

		if (newPlace instanceof SliderPlace) {
			return new SliderActivity(clientFactory);
		}

		/*if (newPlace instanceof AnimationPlace) {
			return new AboutActivity(clientFactory);
		}*/

		if (newPlace instanceof PullToRefreshPlace) {
			return new PullToRefreshActivity(clientFactory);
		}

		if (newPlace instanceof CarouselPlace) {
			return new CarouselActivity(clientFactory);
		}

		if (newPlace instanceof GroupedCellListPlace) {
			return new GroupedCellListActivity(clientFactory);
		}

		if (newPlace instanceof AnimationSlidePlace || newPlace instanceof AnimationSlideUpPlace || newPlace instanceof AnimationDissolvePlace || newPlace instanceof AnimationFadePlace
				|| newPlace instanceof AnimationFlipPlace || newPlace instanceof AnimationPopPlace || newPlace instanceof AnimationSwapPlace || newPlace instanceof AnimationCubePlace || newPlace instanceof AnimationSlideDownPlace) {
			return new AnimationDoneActivity(clientFactory);
		}

		return null;
	}

}
