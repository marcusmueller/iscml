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
package com.googlecode.mgwt.examples.showcase.client.activities.popup;

import java.util.List;

import com.google.gwt.dom.client.Style.Unit;
import com.google.gwt.user.client.ui.FlowPanel;
import com.googlecode.mgwt.dom.client.event.tap.HasTapHandlers;
import com.googlecode.mgwt.examples.showcase.client.DetailViewGwtImpl;
import com.googlecode.mgwt.ui.client.dialog.ConfirmDialog.ConfirmCallback;
import com.googlecode.mgwt.ui.client.dialog.Dialogs;
import com.googlecode.mgwt.ui.client.dialog.Dialogs.OptionCallback;
import com.googlecode.mgwt.ui.client.dialog.Dialogs.OptionsDialogEntry;
import com.googlecode.mgwt.ui.client.widget.Button;

/**
 * @author Daniel Kurka
 * 
 */
public class PopupViewGwtImpl extends DetailViewGwtImpl implements PopupView {

	private Button slideUpButton;
	private Button alertButton;
	private Button confirmButton;

	/**
	 * 
	 */
	public PopupViewGwtImpl() {

		scrollPanel.setScrollingEnabledX(false);

		FlowPanel container = new FlowPanel();
		container.getElement().getStyle().setMarginTop(20, Unit.PX);
		scrollPanel.setWidget(container);

		slideUpButton = new Button("Popup");
		container.add(slideUpButton);

		alertButton = new Button("Alert");

		container.add(alertButton);

		confirmButton = new Button("Confirm");
		container.add(confirmButton);

	}

	@Override
	public HasTapHandlers getSlideUpButton() {
		return slideUpButton;
	}

	@Override
	public HasTapHandlers getAlertButton() {
		return alertButton;
	}

	@Override
	public void alertSomeStuff(String title, String text) {
		Dialogs.alert(title, text, null);

	}

	@Override
	public void confirmSomeStuff(String title, String text, ConfirmCallback callback) {
		Dialogs.confirm(title, text, callback);

	}

	@Override
	public void showSomeOptions(List<OptionsDialogEntry> optionText, OptionCallback callback) {
		Dialogs.options(optionText, callback, main);

	}

	@Override
	public HasTapHandlers getConfirmButton() {
		return confirmButton;
	}

}
