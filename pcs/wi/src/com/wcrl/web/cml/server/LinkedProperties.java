package com.wcrl.web.cml.server;

import java.util.Collections;
import java.util.Enumeration;
import java.util.LinkedHashSet;
import java.util.Properties;

public class LinkedProperties extends Properties {

    /**
	 * 
	 */
	private static final long serialVersionUID = -2015671221859255658L;
	private final LinkedHashSet<Object> keys = new LinkedHashSet<Object>();

    public Enumeration<Object> keys() {
        return Collections.<Object>enumeration(keys);
    }

    public Object put(Object key, Object value) {
        keys.add(key);
        return super.put(key, value);
    }
}

